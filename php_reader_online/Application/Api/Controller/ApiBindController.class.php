<?php

namespace Api\Controller;

/**
 * Class ApiBindController
 * @package Api\Controller
 */
class ApiBindController extends IndexController
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
            try {
                if (empty($data['uuid']))
                {
                    $result['errno'] = self::ERRNO_PARAM_INVALID;
                    break;
                }
                $usersModel = D('Admin/Users');
                if (empty($data['mobile']) || !$usersModel->checkMobile($data['mobile']))
                {
                    $result['data']['result'] = self::CODE_MOBILE_INVALID;
                    break;
                }
                $mobile = $data['areacode'] . $data['mobile'];
                $code = $data['code'];
                if (empty($code) || $code != $usersModel->getSms($mobile))
                {
                    $result['data']['result'] = self::CODE_SMS_CODE_ERR;
                    break;
                }
                $exist = $usersModel->where(['username'=>$mobile])->count();
                if ($exist)
                {
                    $result['data']['result'] = self::CODE_MOBILE_EXIST;
                    break;
                } 
                //注册
                $info = $usersModel->register($data['uuid']);
                if (empty($info))
                {
                    $result['data']['result'] = self::CODE_SERVER_ERR;
                    break;
                }
                $usersModel->where(['id'=>$info['id']])->save(['username'=>$mobile]);
                //token
                $token = $usersModel->setToken($mobile, $data['uuid']);
                $result['data']['result'] = self::CODE_SUCC;
                $result['data']['token'] = $token;
                $result['data']['expire'] = 0;
                if ($info['expire'] > time())
                {
                    $days = ceil(($info['expire'] - time()) / 86400);
                    $result['data']['expire'] = $days;
                }
            } catch (\Exception $e) {
            }
        } while(false);

        return $result;
    }
}