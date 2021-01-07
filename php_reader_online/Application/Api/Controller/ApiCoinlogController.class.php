<?php

namespace Api\Controller;

class ApiCoinlogController extends IndexController
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
            } else {
                $user = $usersModel->register($data['uuid']);
                if (empty($user))
                {
                    $result['data']['result'] = self::CODE_SERVER_ERR;
                    break;
                }
            }
            $info = [];
            $offset = $data['offset'] > 0 ? (int)$data['offset'] : 0;
            $limit = $data['limit'] > 0 ? (int)$data['limit'] : 6;
            $data = D('Admin/CoinLog')->where(['uid'=>(int)$user['id']])->order('create_at desc')->limit($offset, $limit)->select();
            foreach ($data as $val)
            {
                $info[] = [
                    'amount' => $val['amount'],
                    'status' => (int)$val['status'],
                    'type' => (int)$val['type'],
                    'create' => date('Y-m-d H:i:s', $val['create_at'])
                ];
            }
            $result['data']['result'] = self::CODE_SUCC;
            $result['data']['data'] = $info;
    	} while (false);

        return $result;
    }
}