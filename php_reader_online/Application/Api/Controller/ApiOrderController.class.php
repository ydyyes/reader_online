<?php

namespace Api\Controller;
use Helper\Aop\AopClient;
use Helper\Aop\Request\AlipayTradeAppPayRequest;

class ApiOrderController extends IndexController
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

            $notifyUrl = D('SysConfig')->getValue('PAYMENT_BACK_URL');
            if (empty($notifyUrl))
            {
                $result['data']['result'] = self::CODE_SERVER_ERR;
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

            $_id = (string)$data['_id'];
            $serial = (int)$data['serial'];
            $center = (int)$data['center'];
            $days = (int)$data['days'];
            $amount = (float)$data['amount'];
            if (empty($days) || $amount<=0)
            {
                $result['data']['result'] = self::CODE_PARAM_ERR;
                break;
            }
            $orno = "10" . time() . rand(1001, 9999);
            $model = D('Admin/UserPaidLog');
            $model->setStatisticLog($orno, ['_id'=>$_id, 'serial'=>$serial, 'center'=>$center, 'uid'=>$user['id'], 'username'=>$user['username'], 'days'=>$days, 'amount'=>$amount, 'time'=>time(), 'channel'=>$data['channel']]);
            $model->addToQueue($orno);

            $aop = new AopClient();
            $request = new AlipayTradeAppPayRequest();
            $bizContent = json_encode(
                    [
                    'body' => $days,
                    'subject' => '会员充值'.$days,
                    'out_trade_no' => $orno,
                    'timeout_express' => '15m',
                    'total_amount' => $amount,
                    'product_code' => 'QUICK_MSECURITY_PAY',
                    'goods_type' => 0
                ]);
            $request->setBizContent($bizContent);
            $request->setNotifyUrl($notifyUrl);
            $response = $aop->sdkExecute($request);
            $result['data']['result'] = self::CODE_SUCC;
            $result['data']['data']['param'] = $response;
            $result['data']['data']['orno'] = $orno;
    	} while (false);

        return $result;
    }
}