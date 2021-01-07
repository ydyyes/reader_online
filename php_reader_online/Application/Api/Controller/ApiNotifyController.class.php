<?php

namespace Api\Controller;
use Helper\Aop\AopClient;

class ApiNotifyController extends IndexController
{
	public function getData()
    {
    	do {
			if ($_POST)
     		{
     			unset($_POST['req']);
     			if ($_POST['seller_id'] != '2088331126583273' || $_POST['app_id'] != '2018111462163306')
            	{
            		break;
            	}
     			$aop = new AopClient();
     			$verifySign = $aop->rsaCheckV1($_POST, '', $_POST['sign_type']);
     			if ($verifySign)
     			{
     				$model = D('Admin/UserPaidLog');
            		$info = $model->getStatisticLog($_POST['out_trade_no']); 
            		if (empty($info))
            		{
            			break;
            		}
            		if ($info['amount'] != $_POST['total_amount'])
            		{
            			break;
            		}
     				try {
     					$this->orderFile($_POST);
     					$data = [
     						'uid' => $info['uid'],
     						'days' => $info['days'],
                            'channel' => (string)$info['channel'],
     						'pay_ali_or' => $_POST['trade_no'],
     						'pay_or' => $_POST['out_trade_no'],
     						'buyer_id' => $_POST['buyer_id'],
     						'notify_id' => $_POST['notify_id'],
     						'trade_status' => $_POST['trade_status'],
     						'total_amount' => $_POST['total_amount'],
     						'receipt_amount' => (float)$_POST['receipt_amount'],
     						'invoice_amount' => (float)$_POST['invoice_amount'],
     						'buyer_pay_amount' => (float)$_POST['buyer_pay_amount'],
     						'point_amount' => (float)$_POST['point_amount'],
     						'pay_time' => empty($_POST['gmt_payment']) ? time() : strtotime($_POST['gmt_payment']),
     						'create_at' => time(),
     						'status' => in_array($_POST['trade_status'],['TRADE_FINISHED', 'TRADE_SUCCESS']) ? 1 : 0
     					];
     					
     					$ins = $model->add($data);
     				} catch (\Exception $e) {
     					\Think\Log::write($e->getMessage());
     				}

     				if ($ins > 0 && $data['status'] > 0)
     				{
     					try {
     						$user = D('Admin/Users')->where(['id'=>$info['uid']])->find();
     						if ($user['expire'] > 0)
     						{
     							$expire = $user['expire'] + $data['days'] * 86400;
     						} else {
     							$expire = strtotime("+" . $data['days'] . "days");
     						}

     						$cost = $user['cost'] + $data['total_amount'];
     						D('Admin/Users')->where(['id'=>$info['uid']])->save(['expire'=>$expire, 'cost'=>$cost]);
                            D('Admin/Users')->resetToken($info['username']);
     					} catch (\Exception $e) {
     						\Think\Log::write("user expire save faild, data:" .json_encode($data));
     					}
     				}
     			}
     		}
    	} while(false);
     	
     	echo "success";exit;
    }

    public function orderFile(array $data)
    {
    	$dir = ATTACH_PATH . "order/";
    	if (!is_dir($dir))
    	{
    		mkdir($dir, 0755, true);
    	}
    	$file = $dir . date('d') . ".json";
    	file_put_contents($file, date("Ymd H:i:s\ ") . json_encode($_POST) . "\n", FILE_APPEND|LOCK_EX);
    }
}