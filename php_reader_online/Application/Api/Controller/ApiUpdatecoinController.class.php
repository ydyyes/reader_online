<?php

namespace Api\Controller;

class ApiUpdatecoinController extends IndexController
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
            $amount = I('get.amount', '0', 'trim');
            $serial = I('get.serial', '', 'trim');
            $updatefrom = I('get.updatefrom', '0', 'intval');
            $config = C('GAME');
            $check = strtoupper(md5($username . "updatecoin" . $amount . $serial . $updatefrom . $config['updatecoin']));
            if (empty($verifycode) || $verifycode != $check)
            {
                $result['errno'] = self::CODE_GAME_VERIFY_ERR;
                break;
            }
            try {
                $userModel = D('Admin/Users');
                $info = $userModel->getGuser($username);
                if (empty($info))
                {
                    $where = ['guser'=>$username];
                } else {
                    $where = ['id'=>$info['uid']];
                }
                $user = $userModel->where($where)->find();
                $where = ['id'=>$user['id']];
                //事务开启
                M()->startTrans();
                $flag = false;
                $data = [
                    'serial' => $serial, 
                    'uid' => $user['id'],
                    'guser' => $username,
                    'amount' => $amount,
                    'updatefrom' => $updatefrom,
                    'create_at' => time(),
                ];
                try {
                    $add = D('Admin/UpdateCoinOrders')->add($data);
                } catch (\Exception $e) {
                    $result['errno'] = self::CODE_GAME_ORDER_REPEAT;
                    $msg = sprintf("order repeat!  serial[%s] data:%s\n", $serial, json_encode($data));
                    throw new \Exception($msg);
                }
                
                $gamecoin = $userModel->where($where)->getField('gamecoin');
                if ($amount < 0 && $gamecoin < abs($amount))
                {
                    $msg = sprintf("cost faild!  user's gamecoin[%d] is less than amount[%s] data:%s\n", $gamecoin, $amount, json_encode($data));
                    $result['errno'] = self::CODE_GAME_COST_FAILD;
                    throw new \Exception($msg);
                }
                $gamecoin = $gamecoin + $amount;
                $update = $userModel->where($where)->save(['gamecoin'=>$gamecoin]);
                if (abs($amount) == 0 || $update > 0)
                {
                    //事务提交
                    M()->commit();
                    $flag = true;
                    $result['data'] = $gamecoin;
                }                
            } catch (\Exception $e) {
                \Think\Log::write($e->getMessage());
                //事务提交
                M()->rollback();
                $result['errno'] = $result['errno'] > 0 ? $result['errno'] : self::CODE_SERVER_ERR;
            }
        } while (false);

        $this->log(array_merge($data, ['flag'=>$flag]));
        $result['msg'] = self::getErrMsg($result['errno']);
        return $result;
    }

    public function log($data)
    {
        $dir = ATTACH_PATH . date('Ymd') . "/";
        if (!is_dir($dir))
        {
            mkdir($dir, 0777, true);
        }
        file_put_contents($dir . "updatecoin.json", date("[Ymd H:i:s] ") . json_encode($data) . "\n", FILE_APPEND|LOCK_EX);
    }
}