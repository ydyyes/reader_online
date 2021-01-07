<?php

namespace Api\Controller;
use Admin\Model\UsersModel;

class ApiLoginController extends IndexController
{
    public function getData()
    {
        $header = get_headers_info();
        $result = ['errno'=>self::CODE_GAME_SUCC];
        do {
            $token = I('get.token', '', 'trim');
            if (empty($token))
            {
                $result['errno'] = self::CODE_GAME_TOKEN_ERR;
                break;
            }
            $verifycode = I('get.verifycode', '', 'trim');
            $config = C('GAME');
            $check = strtoupper(md5($token . "login" . $config['login']));
            if (empty($verifycode) || $verifycode != $check)
            {
                $result['errno'] = self::CODE_GAME_VERIFY_ERR;
                break;
            }
            $userModel = D('Admin/Users');
            $guser = (string)$userModel->getGtoken($token);
            if (empty($guser))
            {
                $result['errno'] = self::CODE_SERVER_ERR;
                break;
            }
            $info = $userModel->getGuser($guser);
            if (empty($info))
            {
                $where = ['guser'=>$guser];
            } else {
                $where = ['id'=>$info['uid']];
            }
            try {
                // $lock = $userModel->where($where)->getField('lock');
                // if ($lock == UsersModel::LOCK_GAMECOIN_ON)
                // {
                //     throw new \Exception("后台正在操作提现，请稍后重新登录");
                // }
                $userModel->where($where)->save(['lock' => UsersModel::LOCK_GAMECOIN_ON]);
                D('Admin/Users')->setGameLockTimeout($info['uid']);
            } catch(\Exception $e) {
                \Think\Log::write($e->getMessage());
                $result['errno'] = self::CODE_GAME_LOCK_FAILD;
                break;
            }
            
            $result['data'] = $guser;
        } while (false);

        $result['msg'] = self::getErrMsg($result['errno']);
        return $result;
    }
}