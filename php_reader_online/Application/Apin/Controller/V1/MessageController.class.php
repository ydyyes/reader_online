<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Common\Validate\MobileValidate;
use Common\Validate\SmsValidate;
use Helper\Sms;

class MessageController extends BaseController
{
    public function create(){

        $usersModel = D('Admin/Users');
        $mobile = $this->parm['areacode'] . $this->parm['mobile'];
        if ($usersModel->checkSmsOverLimit($this->header['uuid']))
        {
            $this->returnResult(400110);
        }
        //间隔
        if (!$usersModel->checkSmsInterval($mobile))
        {
            $this->returnResult(400112);
        }
        //发送短信
        $code = $this->getCode();
        $sms = C('SMS');
        $msg = $sms['msg_cn'];
        $sms = new Sms($sms['src'], $sms['pwd'], $msg);
        $res = $sms->sendByEnc8($mobile, $code);

        $usersModel->setSmsLimit($this->header['uuid']);
        $usersModel->setSmsInterval($mobile);
        $usersModel->setSms($mobile, $code);
        if ($res)
        {
            $this->returnResult(200,'',[]);
        } else {
            $this->returnResult(2001,'');
        }

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

    public function _check_para($data){
        (new SmsValidate())->gocheck($data);
    }


}