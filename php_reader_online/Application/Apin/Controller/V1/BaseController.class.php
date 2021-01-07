<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\UsersModel;
use Common\Controller\Datasource;
use Common\Controller\Di;
use Common\Controller\HSign;
use Common\Controller\OpenSSLAES;
use Think\Controller;

class BaseController extends Controller
{
    protected $header = [];
    protected $parm;
    protected $userinfo = '';
    protected $login = 2;
    protected $no_uuid = 2;
    public function _initialize(){
          $redis = Datasource::getRedis('instance1');
          $this->header = get_headers_info();

          //自己测试用

          Di::getInstance()->set('AES',OpenSSLAES::class);
          if($_REQUEST['h_req'] != C('WEB_P_CODE')) {

                  if (!$_POST['no']) {
                      $AES = Di::getInstance()->get('AES');
                      $sign = $_POST['sign'];
                      $decrypt = $AES->decrypt($sign);
                      $post_data = json_decode($decrypt, true);
                      if ($post_data) {
                          $this->parm = dhtmlspecialchars($post_data,ENT_QUOTES);
                      }

                      $time = time();
                      if (!$decrypt) {
                          $this->returnResult(500101, '');
                      }

                      if (empty($this->parm['uuid']) || $this->parm['uuid'] != $this->header['uuid']) {
                          $this->returnResult(500101, '');
                      }


                      if (empty($this->parm['vcode']) || $this->parm['vcode'] != $this->header['vcode']) {
                          $this->returnResult(500101, '');
                      }

                      if (empty($this->parm['requestTime']) || ($time - (ceil($this->parm['requestTime'] / 1000)) > C('SIGN_TIME'))) {
                          $this->returnResult(500101, '');
                      }

                      $sign = $redis->get($sign);

                      if ($sign) {
                          $this->returnResult(500101, '');
                      }


                      $redis->set($sign, 1, C('REDIS_SIGN_TIME'));

                      if (method_exists($this, '_check_para')) {
                          $this->_check_para($this->parm);
                      }
                      if ($this->login == 1) {
                          $res = self::check_token($this->parm['token']);
                          if (!$res) {
                              $this->returnResult(300108);
                          }
                      } elseif ($this->login == 2 && $this->no_uuid == 2) {
                          $this->userinfo = self::UUIDLogin();
                      }

                  } else {
                      $post_data = $_POST;
                      $this->parm = dhtmlspecialchars($post_data,ENT_QUOTES);
                      if (method_exists($this, '_check_para')) {
                          $this->_check_para($this->parm);
                      }
                      if ($this->login == 1) {
                          $res = self::check_token($this->parm['token']);
                          if (!$res) {
                              $this->returnResult(300108);
                          }
                      } elseif ($this->login == 2 && $this->no_uuid == 2) {
                          $this->userinfo = self::UUIDLogin();

                      }

                  }
              } else {

                  //web解密
                  $post_data = dhtmlspecialchars($_POST, ENT_QUOTES);
                  $this->parm = $post_data;
                  $h_sign = new HSign();
                  $num_time = session('_HSign');
                  $encode = $num_time;

                  if (!is_numeric($encode) || time() - $encode > C('SIGN_TIME')) {
                      $this->returnResult(500101, '');
                  }

                  if (!($h_sign->getHLimit())) {
                      $this->returnResult(500101, '');
                  }

                  $this->header['uuid'] = C('WEB_UUID');
                  $this->header['channel'] = 'web';
                  if (method_exists($this, '_check_para')) {
                      $this->_check_para($this->parm);
                  }

                  if ($this->login == 1) {
                      $res = self::check_token($this->parm['token']);
                      if (!$res) {
                          $this->returnResult(300108);
                      }
                  } elseif ($this->login == 2 && $this->no_uuid == 2) {
                      $this->userinfo = self::UUIDLogin();

                  }

              }

                  if (!empty($this->parm['size']) && $this->parm['size'] > C('MAX_PAGE_SIZE')) {
                      $this->returnResult(2001, '');
                  }


              }

    public function UUIDLogin(){

        $data = self::createUUid();
        if(!$data){
            $this->returnResult(300102);
        }

        return $data;
    }

      protected function createUUid(){
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

            if(!$by_uuid_info['invitation_code']){
                $data['invitation_code'] = $r_user->createInvitationCode();
                    $r_user->where(['devid' => $this->header['uuid']])
                    ->save(['invitation_code' => $data['invitation_code']]);
            }else{
                $data['invitation_code'] = $by_uuid_info['invitation_code'];
            }

            $data['id'] = $by_uuid_info['id'];
            $data['gold'] = $by_uuid_info['gold'];
            $data['u_type'] = $r_user->userTypes[$by_uuid_info['utid']];
            $data['uni_id'] = $by_uuid_info['uni_id'];
            $data['mobile'] = $by_uuid_info['mobile'];
            $data['username'] = $by_uuid_info['username'];
            $data['nickname'] = $by_uuid_info['nickname'];

            $data['sex']   = $by_uuid_info['sex'];

            $data['cover']  = $by_uuid_info['cover'];



            $data['utid'] = $by_uuid_info['utid'];
            $data['devid'] = $by_uuid_info['devid'];
            $data['login_type'] ='1';

        }else{
            $data['uni_id'] = $r_user->createUinId($this->header['uuid']);
            $data['invitation_code'] = $r_user->createInvitationCode();
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
                'invitation_code' => $data['invitation_code'],
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
            $data['sex']   = -1;
            $data['cover'] = '';

            $data['devid'] = $this->header['uuid'];
            $data['login_type'] = '1';

        }

        return $data;

    }


    //验证Token
    protected function check_token($token){

        if(empty($token)){
            return false;
        }
        $redis = Datasource::getRedis('instance1');
        $this->userinfo = $redis->hgetall($token);

        return $this->userinfo;

    }
    protected function isPositiveInteger($value,  $field='')
    {

        if (is_numeric($value) && is_int($value + 0) && ($value + 0) > 0) {
            return true;
        }
        self::returnResult('400103');
        return false;
    }

    protected function returnResult ( $errorno, $msg='', $data=null,$code =null ){
        header("content:application/json;chartset=uft-8");
        if($code)
         header(http_code($code));

        $errorno =(int)$errorno;
        $msg = $msg?:error_msg($errorno);

        if(isset($data)) {
            if(($_REQUEST['h_req'] != C('WEB_P_CODE')) && (!$_POST['no'])   ){

                $data = json_encode($data);
                $AES = Di::getInstance()->get('AES');
                $en_data = $AES->encrypt($data);
             die(json_encode(['errorno' => $errorno, 'msg' => $msg, 'data' => $en_data], JSON_UNESCAPED_UNICODE));
                }else {
                die(json_encode(['errorno' => $errorno, 'msg' => $msg, 'data' => $data], JSON_UNESCAPED_UNICODE));
            }
        }
            die(json_encode(['errorno'=>$errorno,'msg'=>$msg],JSON_UNESCAPED_UNICODE));
    }
}