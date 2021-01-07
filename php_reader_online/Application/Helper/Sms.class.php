<?php
namespace Helper;

/**
 * Class Sms
 * @package Helper
 */
class Sms
{
    /**
     * 接口根地址
     * @var string
     */
    protected $uri = "http://m.isms360.com:8085";
    //protected $uri = "http://210.51.190.233:8085";

    /**
     * 用户登陆名
     * 必选
     * @var string
     */
    protected $src = "";

    /**
     * 用户登录密码
     * 必选
     * @var string
     */
    protected $pwd = "";

    /**
     * 开通的业务，如SEND，可不填
     * 必选
     * @var string
     */
    protected $servicesid = "";

    /**
     * 目标手机号, 手机号码之间必须用英文逗号分割,最后一个手机号后不加逗号, 群发时一次最多可以同时提交100个号码
     * 目前只支持一个
     * 必选
     * @var string
     */
    protected $dest = "";

    /**
     * 短信编码，0或8
     * 8是中韩日俄等双字节文字（UNICODE编码） ，0是英文（ASII编码）；目前只支持中文
     * 必选
     * @var short
     */
    protected $codec = "";

    /**
     * unicode编码的短信长度最长为70个字(比如中日韩文)
     * ASII编码的短信长度最长为160个字符(英文)
     * 必选
     * @var string
     */
    protected $msg = "您的验证码是：%s（5分钟内有效）。";

    /**
     * en
     */
    protected $msg_ot = "";

    /**
     * 定时时间（约定时间发送）
     * 可选
     * @var string
     */
    protected $time = "";

    /**
     * 可以为空，特服号或者短信显示号码，纯数字字符串，长度<14
     * 可选
     * @var string
     */
    protected $sender = "";

    public function __construct($src, $pwd, $msg="")
    {
        $this->src = $src;
        $this->pwd = $pwd;
        $this->msg = empty($msg) ? $this->msg : $msg;
    }

    public function sendByEnc8($phone, $code)
    {
        $url = sprintf("%s/mt/MT3.ashx", $this->uri);
        $msg = sprintf($this->msg, $code);
        $data = [
            'src' => $this->src,
            'pwd' => $this->pwd,
            'ServiceID' => 'SEND',
            'dest' => $phone,
            'sender' => '',
            'codec' => 8,
            'msg' => $this->toHex(8, $msg)
        ];
        $result = $this->curl($url, $data);
        if ($result > 0)
        {
            return true;
        }
        \Think\Log::write(sprintf("curl -i '%s' -X POST -d '%s' faild, result:%s\n", $url, http_build_query($data), $result));
        return false;
    }

    public function getRestMoney()
    {
        $url = sprintf("%s/querybalance.ashx", $this->uri);
        $data = [
            'User' => $this->src,
            'Pwd' => $this->pwd,
        ];
        $result = $this->curl($url, $data);
        return $result;
    }

    protected function toHex($coding, $str)
    {
        return strtoupper(bin2hex(iconv('UTF-8', 'UCS-2BE', $str)));
    }

    protected function curl($url, $data)
    {
        $ch = curl_init();
        curl_setopt ( $ch, CURLOPT_URL, $url);
        curl_setopt ( $ch, CURLOPT_POST, 1 );
        curl_setopt ( $ch, CURLOPT_HEADER, 0 );
        curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt ( $ch, CURLOPT_POSTFIELDS, $data );
        $return = curl_exec ( $ch ); //$return  返回结果，如果是以 “-” 开头的为发送失败，请查看错误代码，否则为MSGID
        curl_close ( $ch );
        return $return;
    }

}

class Sms_Exception extends \Exception {
}