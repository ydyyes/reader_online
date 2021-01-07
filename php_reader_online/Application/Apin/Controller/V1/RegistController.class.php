<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\TaskModel;
use Admin\Model\UsersModel;
use Common\Controller\Datasource;
use Common\Validate\LoginValidate;
use Common\Validate\MobileValidate;

class RegistController extends BaseController
{   protected $is_mobile = '';
    public function create(){

        //赋值验证
        (new MobileValidate())->gocheck($this->parm);

        $code  = $this->parm['code'];
        $mobel = $this->parm['areacode'].$this->parm['mobile'];

        //权限账号免验证
        if($this->parm['mobile'] == C('USER_ADMIN_LOGIN') && $this->parm['code'] == C('USER_ADMIN_CODE')){

            $data = self::AdminLoginMobile($this->parm['mobile']);

        }else {
            $data = self::LoginMobile($mobel, $code);
        }


        if(!$data){
            $this->returnResult(300102);
        }

        //生产Token
            $res = [];
            $r_user = D('Admin/Users');
            $token = $r_user->createToken($this->header['uuid'], $data);
            if (!$token) {
                $this->returnResult(300103);
            }
            if ($token == 'token_limit') {
                $this->returnResult(300110);
            }
            $res['token'] = $token;

            $res['u_type'] = $data['u_type'];
            $res['uni_id'] = $data['uni_id'];
            $res['sex']    = $data['sex'];
            $res['cover']  = $data['cover'];
            $res['nickname']  = $data['nickname'];
            if($data['cover'])
                $res['cover'] = strrpos($data['cover'], 'http') ? $data['cover'] : cdn('ATTACH') . $data['cover'];
            else
                $res['cover'] = '';
            //阅读时长
            $task_model = D('Admin/Task');
            $res['reader_time'] = $task_model -> getTaskReaderTimeCache($data['id']);


            $res['gold'] = $data['gold'];
            $res['invitation_code'] = $data['invitation_code'];
            $res['expire'] = $data['expire'];
            return $this->returnResult(200,'',$res);

    }

    //UUID检测及登录

//    public function UUIDLogin(){
//
//        $data = self::createUUid();
//
//        if(!$data){
//            $this->returnResult(300102);
//        }
//
//        return $data;
//    }
    protected  function AdminLoginMobile($mobile){
        $r_user = D('Admin/Users');
        $by_mobile_info = $r_user->findByMobile($this->parm['mobile']);

        if(!$by_mobile_info){
            $this->returnResult(2001);
        }

        //查看是否有会员
        $res = $r_user->getVipData($by_mobile_info['expire']);
        if ($res) {
            $data['expire'] = $by_mobile_info['expire'];
        } else {
            $data['expire'] = '0';
            
        }

        $data['id'] = $by_mobile_info['id'];
        $data['uni_id'] = $by_mobile_info['uni_id'];
        $data['gold'] = $by_mobile_info['gold'];
        $data['devid'] = $by_mobile_info['devid'];
        $data['invitation_code'] = $by_mobile_info['invitation_code']?:'';
        $data['utid'] = $by_mobile_info['utid'];
        $data['u_type'] = $r_user->userTypes[$by_mobile_info['utid']];

        $data['sex']   = $by_mobile_info['sex'];

        $data['cover'] = $by_mobile_info['cover'];


        $data['username'] = $by_mobile_info['username'];
        $data['mobile'] = $by_mobile_info['mobile'];
        $data['nickname'] = $by_mobile_info['nickname'];
        $data['login_type'] = '2';

        return $data;


    }


    protected  function LoginMobile($mobile,$code){
        $r_user = D('Admin/Users');
        //短信登录
        if (empty($code) || $code != $r_user->getSms($mobile))
        {
            $this->returnResult(400111);
        }

        //用户检测
        $user_info = $this->userinfo;

        $by_mobile_info = $r_user->findByMobile($this->parm['mobile']);

       if($by_mobile_info) {

           if($by_mobile_info['status'] != UsersModel::STATUS_ON){
               $this->returnResult(300111);
           }
           //查看是否有会员
           $res = $r_user->getVipData($by_mobile_info['expire']);
           if ($res) {
               $data['expire'] = $by_mobile_info['expire'];
           } else {
               $data['expire'] = '0';

           }
           if(!$by_mobile_info['invitation_code']) {
               //如果邀请码,不存在就生成邀请码
               $data['invitation_code'] = $r_user->createInvitationCode();
               $user_set = $r_user -> where(['id' => $by_mobile_info['id'] ])->setField('invitation_code',$data['invitation_code']);

               if($user_set){
                   $redis = Datasource::getRedis('instance1');
                   $list = $redis->hgetall($by_mobile_info['uni_id']);
                   foreach ($list as $k => $v){
                       if($redis->hget($k,'uni_id')){
                           $redis->hset($k,'invitation_code', $data['invitation_code']);
                       }
                   }
               }

           }

           $data['id'] = $by_mobile_info['id'];
           $data['uni_id'] = $by_mobile_info['uni_id'];
           $data['gold'] = $by_mobile_info['gold'];
           $data['devid'] = $by_mobile_info['devid'];
           $data['utid'] = $by_mobile_info['utid'];
           $data['invitation_code'] = $by_mobile_info['invitation_code']?:'';
           $data['u_type'] = $r_user->userTypes[$by_mobile_info['utid']];
           $data['sex']   = $by_mobile_info['sex'];
           $data['cover'] = $by_mobile_info['cover'];



           $data['username'] = $by_mobile_info['username'];
           $data['mobile'] = $by_mobile_info['mobile'];
           $data['nickname'] = $by_mobile_info['nickname'];
           $data['login_type'] = '2';
       }else{
           //注册接口


               if(!empty($this->userinfo['mobile'])){
                   $this->returnResult(300109);
               }


               $by_mobile_info = $r_user->CheckBindMobile($this->parm['mobile']);

               if($by_mobile_info){
                   $this->returnResult(300109);
               }

               $res = $r_user->bindPhone($this->parm['mobile'],$this->header,$user_info['utid']);
               if(!$res){
                   $this->returnResult(300102);
               }


               //任务
               $task_model =  D('Admin/Task');
               $task_type = TaskModel::TASK_TYPE_BIND;
               $where['task_type'] = $task_type;
               $where['status'] = TaskModel::STATUS_ON;
               //查看任务是否开放
               $task_data = $task_model->where($where)->find();
               $function = $task_model->task_function[$task_type];
               if($task_data){

                   $reflection =  new \ReflectionClass(\Common\Reflect\TaskController::class);
                   $instantiation= $reflection->newInstance();
                   $res = $instantiation->$function($task_data,[$this->userinfo['uni_id'],$this->userinfo['id']],$this->header['channel']);
                   if($res){

                       $by_mobile_info = $r_user->CheckBindMobile($this->parm['mobile']);
                       if($by_mobile_info){
                           $user_info['expire'] = $by_mobile_info['expire'];
                           $user_info['gold'] = $by_mobile_info['gold'];

                       }

                   }

               }

               //查看是否有会员
               $res = $r_user->getVipData($user_info['expire']);
               if ($res) {
                   $data['expire'] = $user_info['expire'];
               } else {
                   $data['expire'] = '0';
               }

               $data['id'] = $user_info['id'];
               $data['uni_id'] = $user_info['uni_id'];
               $data['gold'] = $user_info['gold'];
               $data['devid'] = $user_info['devid'];
               $data['utid'] = $user_info['utid'];
               $data['invitation_code'] = $user_info['invitation_code']?:'';
               $data['u_type'] = $r_user->userTypes[$user_info['utid']];
               $data['sex']   = $user_info['sex'];
               $data['cover'] = $user_info['cover'];
               $data['username'] = $user_info['username'];
               $data['mobile']   = $this->parm['mobile'];
               $data['nickname'] = $user_info['nickname'];
               $data['login_type'] = '2';


       }



        return $data;
    }

   /* protected function createUUid(){
        $r_user = D('Admin/Users');
        $by_uuid_info = $r_user->findByUUid($this->header['uuid']);
        $data = [];
        if($by_uuid_info){
            //查看是否有会员
            $res = $r_user->getVipData($by_uuid_info['expire']);
            $data['expire'] = '0';
            if($res){
                $data['expire'] = $by_uuid_info['expire'];
            }
            $data['id'] = $by_uuid_info['id'];
            $data['gold'] = $by_uuid_info['gold'];
            $data['u_type'] = $r_user->userTypes[$by_uuid_info['utid']];
            $data['uni_id'] = $by_uuid_info['uni_id'];
            $data['mobile'] = $by_uuid_info['mobile'];
            $data['username'] = $by_uuid_info['username'];
            $data['nickname'] = $by_uuid_info['nickname'];
            $data['utid'] = $by_uuid_info['utid'];
            $data['devid'] = $by_uuid_info['devid'];
            $data['login_type'] ='1';

        }else{
            $data['uni_id'] = $r_user->createUinId($this->header['uuid']);
            $expire = D('SysConfig')->getValue('USER_NO_ADS') ? : 1;
            $expire = $expire*24*60*60;
            $expire = time()+$expire;

            $user=[
                'devid'  => $this->header['uuid'],
                'uni_id' => $data['uni_id'],
                'utid'   => UsersModel::USER_TYPE_VISITOR,
                'status' => UsersModel::STATUS_ON,
                'expire' => $expire,
                'model'  => $this->header['model']?:'',
                'vcode'  => $this->header['vcode']?:'',
                'channel'=> $this->header['channel']?:'',
                'create_time' => time(),
                'update_time' => time()
            ];
            $res = $r_user->add($user);


            if(!$res){
                $this->returnResult(300102);
            }
            $data['gold'] = '0';
            $data['id'] = $res;
            $data['expire'] = $expire;
            $data['u_type'] = $r_user->userTypes['USER_TYPE_VISITOR'];
            $data['utid'] = '1';
            $data['mobile'] = '';
            $data['username'] = '';
            $data['nickname'] = '';
            $data['devid'] = $this->header['uuid'];
            $data['login_type'] = '1';

        }

            return $data;

    }*/


}