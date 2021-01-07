<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\TaskModel;
use Common\Validate\MobileValidate;

class BindPhoneController extends BaseController
{

    public function create(){

            $user_info = $this->userinfo;

            $r_user = D('Admin/Users');
            $code = $this->parm['code'];
            $mobile = $this->parm['areacode'].$this->parm['mobile'];
            if (empty($code) || $code != $r_user->getSms($mobile))
            {
                $this->returnResult(400111);
            }


            if(empty($this->header['uuid'])){
                $this->returnResult(300100);
            }



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
            $data['u_type'] = $r_user->userTypes[$user_info['utid']];
            $data['username'] = $user_info['username'];
            $data['mobile'] = $user_info['mobile'];
            $data['nickname'] = $user_info['nickname'];

            $data['sex'] = $user_info['sex'];
            if($user_info['cover'])
                $data['cover'] = strrpos($user_info['cover'], 'http') ? $user_info['cover'] : cdn('ATTACH') . $user_info['cover'];
            else
                $data['cover'] = '';


            $data['login_type'] = '2';

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
            $res['token']  = $token;
            $res['uni_id'] = $data['uni_id'];
            $res['u_type'] = $data['u_type'];
            $res['gold']   = $data['gold'];
            $res['expire'] = $data['expire'];
            $res['nickname'] = $data['nickname'];
            $res['sex'] = $data['sex'];
            $res['cover'] = strrpos($user_info['cover'], 'http') ? $user_info['cover'] : cdn('ATTACH') . $user_info['cover'];


        return $this->returnResult(200,'',$res);

    }

    protected function _check_para($data){

        (new MobileValidate())->gocheck($data);

    }

}