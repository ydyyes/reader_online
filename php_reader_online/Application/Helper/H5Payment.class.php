<?php
namespace Helper;

/**
 * http://api.local.video/api.php?req=qrcode&uuid=1231121d1o312ikjasd150&pkgname=mitao.app&vcode=111&token=f033ca65b72d1f6eb575c3856a6f3e7b&pid=3&payby=2
 * Class Payment
 * @package Helper
 */
class H5Payment
{
    /**
     * 支付请求地址
     * @var string
     */
    protected $uri = "http://47.75.206.119/payserver/x2xpay/doRequest.action";

    /**
     * 报文头
     * @var array
     */
    protected $head = [
        'appId'         =>  'DEFAULT',
        'version'       =>  '1.0',
        'reqType'       =>  '',
        'mchid'         =>  '177800000004428',
        'reqNo'         =>  '',
        'channel'       =>  '',
//        'clientIp'      =>  '',
        'backURL'       =>  ''
    ];

    /**
     * 支付参数
     * @var array
     */
    protected $payParams = [
        'paytype'         => 0,
        'total_fee'       => 0,
        //'device_ip'       => '',
        'subject'         => 'h5payment',
    ];

    protected $queryParams = [
        'ori_seq' => '',
    ];

    /**
     * H5Payment constructor.
     * @param $data
     */
    public function __construct($data)
    {
        $this->head['reqType'] = !empty($data['reqType']) ? $data['reqType']: "h5_pay_request";
        $this->head['reqNo'] = !empty($data['reqNo']) ? $data['reqNo'] : "";
        $this->head['channel'] = isset($data['channel']) ? $data['channel'] : "";
        $this->head['backURL'] = !empty($data['backURL']) ? $data['backURL'] : "";
        $this->payParams['paytype'] = isset($data['paytype']) ? (int)$data['paytype'] : 0;
        $this->payParams['total_fee'] = !empty($data['total_fee']) ? (int)$data['total_fee'] : 0;
        $this->payParams['subject'] = !empty($data['subject']) ? $data['subject'] : 'h5payment';
    }

    public function getQRCode()
    {
        $info = ['qrcode' => '', 'msg' => ''];
        $params = array_merge($this->head, $this->payParams);
        ksort($params);
        $value = implode('', $params);
        $sign = $this->sign($value);
        if (false === $sign)
        {
           return $info;
        }
        $this->head['sign'] = $sign;
        $data = [
            'head' => $this->head,
            'data' => $this->payParams,
        ];
        $data = $this->arrToXml($data);
        $res = $this->sendReq($this->uri, $data);
        $res = $this->resultProcessing($res);
        file_put_contents(ATTACH_PATH . "pay_data.log", "data: " . $data . "\nres:" . json_encode($res) . "\n\n", FILE_APPEND|LOCK_EX);
        $result = $this->verify($res);
        if($result){
            //验签通过
            $info['code'] = $res['head']['respCd'];
            $info['msg'] = $res['head']['respMsg'];
            if(!empty($res['data']['pay_url'])){
                $info['qrcode'] = $res['data']['pay_url'];
            }
        }
        return $info;
    }

    public function orderQuery()
    {
        $params = array_merge($this->head, $this->queryParams);
        ksort($params);
        $value = implode('', $params);
        $this->head['sign'] = $this->sign($value);
        $data = [
            'head' => $this->head,
            'data' => $this->queryParams,
        ];
        $data = $this->arrToXml($data);
        $res = $this->sendReq($this->uri, $data);
        $res = $this->resultProcessing($res);
        $result = $this->verify($res);
        var_dump($result);
    }

    /**
     * 传输数据
     * @param $url
     * @param $data
     * @param string $contentType
     * @return string
     */
    public function sendReq($url, $data, $contentType = 'text/xml')
    {
        if (!is_string($data)) {
            $postdata = http_build_query($data);
        } else {
            $postdata = $data;
        }
        $opts = array(
            'http' => array(
                'method' => 'POST',
                'header' => 'content-type:' . $contentType,
                'content' => $postdata
            )
        );
        $context = stream_context_create($opts);
        ini_set('user_agent', 'Mozilla/4.0 (compatible; MSIE 5.00; Windows 98)');
        $result = file_get_contents($url, true, $context);
        if (false === strpos($result, '0000'))
        {
            $msg = sprintf("req postdata[%s] res data[%s]\n", $postdata, $result);
            \Think\Log::write($msg);
        }
        return $result;
    }

    /**
     * 数组转xml
     * @param $arr array
     * @param null $key xml键名 传空格则不包含<xml></xml>  不传则包含<xml></xml>
     * @return string
     */
    public function arrToXML($arr, $key = null)
    {
        if (!$key) {
            $str = '<xml>';
        } else if ($key == ' ') {
            $str = '';
        } else {
            $str = '<' . $key . '>';
        }
        foreach ($arr as $k => $v) {
            if (is_array($v)) {
                $str .= $this->arrToXML($v, $k);
            } else {
                $str .= "<" . $k . ">" . $v . "</" . $k . ">";
            }
        }
        if (!$key) {
            $str .= "</xml>";
        } else if ($key == ' ') {
            $str .= '';
        } else {
            $str .= '</' . $key . '>';
        }
        return $str;
    }

    /**
     * xml转数组
     * @param $xml
     * @return mixed
     */
    public static function xmlToArr($xml)
    {
        //禁止引用外部xml实体
        libxml_disable_entity_loader(true);
        $values = json_decode(json_encode(simplexml_load_string($xml, 'SimpleXMLElement', LIBXML_NOCDATA)), true);
        return $values;
    }

    /**
     * 密钥加签
     * @param $data
     * @param int $signMethod
     * @return bool|string
     */
    public function sign($data, $signMethod = OPENSSL_ALGO_MD5)
    {
        $verifyKey4Server = file_get_contents(ATTACH_PATH . "pay.pem");
        $res = openssl_pkey_get_private($verifyKey4Server);
        if (openssl_sign($data, $out, $res, $signMethod)) {
            //释放资源
            openssl_free_key($res);
            return (base64_encode($out));
        }
        return false;
    }

    /**
     * 密钥验签 平台公钥
     * @param $sign string 密文
     * @param $data string 原文
     * @return int
     */
    public function verifySign($sign, $data, $signMethod = OPENSSL_ALGO_SHA1)
    {
        $verifyKey4Server = 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQChBzU1HlgGXiDXHccasc115JGQW56rwQ/UKKZ6CVYuyUrs5YKcpRGgl4HRL1/WcfgBt7K+RVoM3QoUsQLmkuZS5RE2jCjkpxG7r+wwkfXmLs67fRQSlRrANsmRbFVSHZimNiu5JJGe/2qUyww/vzz1iCNrVy+HXyVxe2rarmOxlwIDAQAB';
        $pem = chunk_split($verifyKey4Server, 64, "\n");//转换为pem格式的公钥
        $pem = "-----BEGIN PUBLIC KEY-----\n" . $pem . "-----END PUBLIC KEY-----\n";
        $verifyKey = openssl_pkey_get_public($pem);
        $sign = base64_decode($sign);
        $r = openssl_verify($data, $sign, $verifyKey, $signMethod);
        openssl_free_key($verifyKey);
        return $r;
    }

    /**
     * $result string 接受结果字符串
     * @param $result
     * @return mixed
     * @throws \Exception
     */
    public function resultProcessing($result)
    {
        try {
            if (!$result || is_array(json_decode($result, 1))) {
                throw new \Exception($this->errorInfo($this->getHelpLang('service.error')));
            }
            $resultArr = $this->xmlToArr($result);
            return $resultArr;
        } catch (Exception $exception) {
            \Think\Log::write($exception->getMessage());
        }
    }

    /**
     * 获取转成json数据的返回信息
     * @param $msg   int           信息码  1成功，其他失败
     * @param $info  string           提示信息
     * @param null|array $data list数据或者信息数据
     * @param null|array $option 额外参数
     * @return string
     */
    function getReturnInfo($msg, $info, $data = null, $option = null)
    {
        $arr = ['msg' => $msg, 'info' => $info];
        if ($data) {
            $arr['data'] = $data;
        }
        if ($option) {
            foreach ($option as $k => $v) {
                $arr[$k] = $v;
            }
        }
        $result = json_encode($arr);
        return $result;
    }

    /**
     * 获取错误信息格式数据
     * @param $info string 提示信息
     * @return string
     */
    function errorInfo($info, $code = 0)
    {
        return $this->getReturnInfo($code, $info);
    }

    /**
     * 获取提示语句
     * @param $info
     * @return string
     */
    function getHelpLang($info)
    {
        $configs = explode('.', $info);
        $str = '';
        foreach ($configs as $config) {
            $str .= $config;
        }
        return $str;
    }

    //验签函数
    public function verify($res){
        try {
            //验签数据准备 降维 排序 拼接 验签
            $tmp = array();
            foreach($res as $ke => $val){
                if(!empty($val)||$val == 0){
                    foreach($val as $k=>$v){
                        if(!empty($v||$v == 0)){
                            $tmp[$k]=$v;
                        }
                    }
                }
            }

            unset($tmp['sign']);
            ksort($tmp);
            $str = '';
            foreach ($tmp as $key => $value){
                $str .= $value;
            }
            $result = $this->verifySign($res['head']['sign'],$str,OPENSSL_ALGO_MD5);
            return $result;
        } catch (Exception $e) {
            return false;
        }
    }
}