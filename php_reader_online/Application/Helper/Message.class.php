<?php
/**
 * Message.class.php
 * 
 * @author    allenqin <allenqinhai@gmail.com>
 * @version   1.0
 * CreatTime  2015年3月16日 下午6:28:39
 */
namespace Helper;

/**
 * 手机验证码发送
 * 
 * @author allenqin<allenqinhai@gmail.com>
 */
class Message
{
    const SUCCESS   = 0;
    const ERROR     = "短信发送失败";
    
    /**
     * 检查手机号是否合法
     * @param unknown $phone
     */
    public function phone_checker($phone)
    {
    	$reg = "^13[0-9]{9}|15[012356789][0-9]{8}|18[0-9]{9}|14[579][0-9]{8}|17[0-9]{9}$";
    	return preg_match("@{$reg}@is", $phone);
    }
    
    /**
     * 发送短信验证码
     * 
     * @param string $mobile  指定发送到的手机号
     * @param string $code    验证码
     *
     * @author allenqin <allenqinhai@gmail.com>
     */
    public function sendVerifyMsg($mobile, $code)
    {
    	$error = [
    			"0"		=>"短信提交成功",
    			"-1"	=>"参数不正确",
    			"-1"	=>"参数不正确，短信内容签名不规范",
    			"-2"	=>"非法账号",
    			"-3"	=>"IP鉴权失败",
    			"-4"	=>"账号余额不足",
    			"-5"	=>"下发失败",
    			"-6"	=>"短信内容含有非法关键字",
    			"-7"	=>"同一个号码、同一段短信内容，在同一小时内重复下发",
    			"-8"	=>"拓展特服号码不正确",
    			"-9"	=>"非法子账号",
    			"-10"	=>"定时计划时间不正确",
    			"-11"	=>"CID不正确",
    			"-13"	=>"一次性提交手机号码过多",
    			"-16"	=>"接口调用错误次数太多",
    	];
    	
    	$data = "uid=a2C5Ix0ndVMf&pas=xrn3z9r4&mob={$mobile}&cid=gnbaANpaf2knull&p1={$code}&type=json";

    	$data = "uid=EkcTyiNEyeAZ&pas=93vxfqwj&mob={$mobile}&cid=q4iTPglk9skk&p1={$code}&type=json";
    	
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "http://api.weimi.cc/2/sms/send.html");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
        curl_setopt($ch, CURLOPT_POST, TRUE);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        
        $res = curl_exec( $ch );
        curl_close( $ch );
        $result = json_decode($res, true);

        if($result['code'] < 0)
        	D("SysErrorLog")->setVar('mssage_info', $data)->setVar('mssage_result', $result)->log("手机短信发送失败", "EMERG", false, false);
        
        return $result['code'] == 0 ? self::SUCCESS : self::ERROR;
    }
}