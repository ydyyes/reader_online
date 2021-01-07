<?php

namespace Api\Controller;

class ApiGloginController extends IndexController
{
    public function getDecryptData($data)
    {
        return $this->core($data);
    }

    public function getData()
    {
        $header = get_headers_info();
        $data = array_merge($header, $_GET);
        return $this->core($data);
    }

    protected function core($data)
    {
    	$result = ['errno'=>0, 'data'=>[]];
    	do {
    		if (empty($data['uuid']))
            {
                $result['errno'] = self::ERRNO_PARAM_INVALID;
                break;
            }
            //注册
            $userModel = D('Admin/Users');
            if (isset($data['token']))
            {
                $user = D('Admin/Users')->getToken($data['token']);
                $user = $userModel->where(['id'=>(int)$user['id']])->find();
            } else {
                $user = $userModel->register($data['uuid']);
            }
            if (empty($user))
            {
                $result['data']['result'] = self::CODE_SERVER_ERR;
                break;
            }
            $token = $userModel->setGtoken($user['guser'], $user['id']);
            $result['data']['token'] = $token;
            $result['data']['gamecoin'] = $user['gamecoin'];
    	} while (false);

        return $result;
    }
}