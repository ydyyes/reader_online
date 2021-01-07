<?php

namespace Api\Controller;

use Helper\Sms;

/**
 * Class ApiSmsController
 * @package Api\Controller
 */
class ApiSmsController extends IndexController
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
                $usersModel = D('Admin/Users');
                if (empty($data['uuid']))
                {
                    $result['errno'] = self::ERRNO_PARAM_INVALID;
                    break;
                }
                //注册
                $info = $usersModel->register($data['uuid']);
                if (empty($info))
                {
                    $result['data']['result'] = self::CODE_SERVER_ERR;
                    break;
                }
                if (empty($data['mobile']) || !$usersModel->checkMobile($data['mobile']))
                {
                    $result['data']['result'] = self::CODE_MOBILE_INVALID;
                    break;
                }

                $mobile = $data['areacode'] . $data['mobile'];
                //发送次数
                if ($usersModel->checkSmsOverLimit($data['uuid']))
                {
                    $result['data']['result'] = self::CODE_SMS_OVER_LIMIT;
                    break;
                }
                //间隔
                if (!$usersModel->checkSmsInterval($mobile))
                {
                    $result['data']['result'] = self::CODE_SMS_INTERVAL_TOO_SHORT;
                    break;
                }

                //发送短信
                $code = $this->getCode();
                $sms = C('SMS');
                $msg = $sms['msg_cn'];
                $sms = new Sms($sms['src'], $sms['pwd'], $msg);
                $res = $sms->sendByEnc8($mobile, $code);

                $usersModel->setSmsLimit($data['uuid']);
                $usersModel->setSmsInterval($mobile);
                $usersModel->setSms($mobile, $code);
                if ($res)
                {
                    $result['data']['result'] = self::CODE_SUCC;
                } else {
                    $result['data']['result'] = self::CODE_FAILD;
                }
            } catch (\Exception $e) {
            }
        } while(false);

        return $result;
    }

    public function getCode()
    {
        $numbers = range(0, 9);
        $length = 4;
        $code = "";
        for ($i=0; $i<$length; $i++)
        {
            $code .= $numbers[rand(0, 9)];
        }

        return $code;
    }

}