<?php

namespace Api\Controller;
use Admin\Model\WithdrawLogModel;
use Admin\Model\CoinLogModel;
use Admin\Model\UsersModel;

class ApiWithdrawController extends IndexController
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

            $userlock = "withdraw_" . $user['id'];
            if (S($userlock))
            {
                $result['data']['result'] = self::CODE_WITHDRAW_ERR;
                break;
            }
            S($userlock, 1, 5);

            $order = [];
            $order['uid'] = $user['id'];
            $order['gamecoin'] = (int)$data['gamecoin'];
            $order['alipay'] = (string)$data['alipay'];
            $order['aliname'] = (string)$data['aliname'];
            $order['contact'] = (string)$data['contact'];
            $order['total_amount'] = (float)$data['amount'];
            if (empty($order['gamecoin']) || empty($order['alipay']) || empty($order['total_amount']) || empty($order['contact']))
            {
                $result['data']['result'] = self::CODE_PARAM_ERR;
                break;
            }
            $giftcoin = UsersModel::GIFTCOIN_NUM;
            if ($user['giftcoin'] > 0)
            {
                if ($user['gamecoin'] <= $giftcoin || $user['gamecoin'] - $giftcoin < $order['gamecoin'])
                {
                    $result['data']['result'] = self::CODE_WITHDRAW_ERR;
                    break;
                }
            } else {
                if ($user['gamecoin'] < $order['gamecoin']) 
                {
                    $result['data']['result'] = self::CODE_WITHDRAW_ERR;
                    break;
                }
            }
            if ($order['gamecoin'] / 10000 != $order['total_amount'])
            {
                $result['data']['result'] = self::CODE_WITHDRAW_ERR;
                break;
            }

            
            $order['receipt_amount'] = $order['total_amount'] * (1 - D('Admin/WithdrawLog')->radio);
            $order['orno'] = "30" . time() . rand(1001, 9999);
            $order['pay_ali_or'] = '';
            $order['create_at'] = $order['update_at'] = time();
            try {
                // if ($user['lock'] == UsersModel::LOCK_GAMECOIN_ON)
                // {
                //     $result['data']['result'] = self::CODE_GAME_LOCK_FAILD;
                //     break;
                // }
                // D('Admin/Users')->where(['id'=>$user['id']])->save(['lock'=>UsersModel::LOCK_GAMECOIN_ON]);
                $ins = D('Admin/WithdrawLog')->add($order);
                if ($ins > 0)
                {
                    $cost = $user['cost'] - $order['receipt_amount'];
                    $gamecoin = $user['gamecoin'] - $order['gamecoin'];
                    D('Admin/Users')->where(['id'=>$user['id']])->save(['gamecoin'=>$gamecoin, 'cost'=>$cost]);
                }
                // D('Admin/Users')->where(['id'=>$user['uid']])->save(['lock'=>UsersModel::LOCK_GAMECOIN_OFF]);
                $coinlog = [
                    'uid' => $order['uid'],
                    'orno' => $order['orno'],
                    'amount' => $order['receipt_amount'],
                    'status' => WithdrawLogModel::STATUS_APPEND,
                    'type' => CoinLogModel::TYPE_WITHDRAW,
                    'create_at' => $order['create_at'],
                    'update_at' => $order['create_at'],
                ];
                D('Admin/CoinLog')->add($coinlog);
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