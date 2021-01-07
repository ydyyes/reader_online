<?php

namespace Api\Controller;

/**
 * Class ApiUserinfoController
 * @package Api\Controller
 */
class ApiUserinfoController extends IndexController
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
                if (isset($data['token']))
                {
                    $user = $usersModel->getToken($data['token']);
                    if (empty($user) || $user['logDevid'] != $data['uuid'])
                    {
                        $result['data']['result'] = self::CODE_TOKEN_INVALID;
                        break;
                    }
                    $userDb = $usersModel->where(['username'=>$user['username']])->find();
                    $user = array_merge($user, $userDb);
                } else {
                    $user = $usersModel->register($data['uuid']);
                    if (empty($user))
                    {
                        $result['data']['result'] = self::CODE_SERVER_ERR;
                        break;
                    }
                }
                $result['data']['result'] = self::CODE_SUCC;
                $result['data']['expire'] = 0;
                if ($user['expire'] > time())
                {
                    $days = ceil(($user['expire'] - time()) / 86400);
                    $result['data']['expire'] = $days;
                }
                $result['data']['gamecoin'] = $user['gamecoin'];
                $result['data']['giftcoin'] = $user['giftcoin'];
            } catch (\Exception $e) {
            }
        } while(false);

        return $result;
    }
}