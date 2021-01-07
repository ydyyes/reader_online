<?php

namespace Api\Controller;
use Admin\Model\UsersModel;

class ApiGiftcoinController extends IndexController
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

            $usersModel = D('Admin/Users');
            if (isset($data['token']))
            {
                $user = $usersModel->getToken($data['token']);
                if (empty($user) || $user['logDevid'] != $data['uuid'])
                {
                    $result['data']['result'] = self::CODE_TOKEN_INVALID;
                    break;
                }
                $user = $usersModel->where(['id'=>$user['id']])->find();
            } else {
                $user = $usersModel->register($data['uuid']);
            }

            if (empty($user))
            {
                $result['data']['result'] = self::CODE_SERVER_ERR;
                break;
            }
            
            $gift = (int)$data['gift'];
            try {
                if ($gift > 0)
                {
                    if ($user['giftcoin'] > 0)
                    {
                        $result['data']['result'] = self::CODE_GIFTCOIN_REPEAT;
                        break;
                    }
                    $giftcoin = UsersModel::GIFTCOIN_NUM;
                    $gamecoin = $user['gamecoin'] + $giftcoin;
                    D('Admin/Users')->where(['id'=>$user['id']])->save(['gamecoin'=>$gamecoin, 'giftcoin'=>$giftcoin]);
                }
            } catch (\Exception $e) {
                \Think\Log::write($e->getMessage);
                $result['data']['result'] = self::CODE_SERVER_ERR;
                break;
            }
            
            $result['data']['result'] = self::CODE_SUCC;
    	} while (false);

        return $result;
    }
}