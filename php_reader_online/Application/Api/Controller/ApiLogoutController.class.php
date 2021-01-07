<?php

namespace Api\Controller;
use Admin\Model\UsersModel;

class ApiLogoutController extends IndexController
{
    public function getData()
    {
        $header = get_headers_info();
        $result = ['errno'=>self::CODE_GAME_SUCC];
        do {
            $username = I('get.username', '', 'trim');
            if (empty($username) || strlen($username) != 32)
            {
                $result['errno'] = self::CODE_GAME_USERNAME_ERR;
                break;
            }
            $verifycode = I('get.verifycode', '', 'trim');
            $config = C('GAME');
            $check = strtoupper(md5($username . "logout" . $config['login']));
            if (empty($verifycode) || $verifycode != $check)
            {
                $result['errno'] = self::CODE_GAME_VERIFY_ERR;
                break;
            }
            $userModel = D('Admin/Users');
            $info = $userModel->getGuser($username);
            if (empty($info))
            {
                $where = ['guser'=>$username];
            } else {
                $where = ['id'=>$info['uid']];
            }
            try {
                $userModel->where($where)->save(['lock' => UsersModel::LOCK_GAMECOIN_OFF]);
                D('Admin/Users')->delGameLockTimeout($info['uid']);
            } catch(\Exception $e) {
                \Think\Log::write($e->getMessage());
                $result['errno'] = self::CODE_GAME_RELEASE_FAILD;
                break;
            }
        } while (false);

        $result['msg'] = self::getErrMsg($result['errno']);
        return $result;
    }
}