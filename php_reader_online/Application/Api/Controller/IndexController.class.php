<?php
namespace Api\Controller;

use Helper\Aes;

class IndexController extends BaseController
{
    //参数非法
    const ERRNO_PARAM_INVALID = 1001;
    //成功,失败,服务器错误
    const CODE_SUCC = 2000;
    const CODE_FAILD = 2999;
    const CODE_SERVER_ERR = 9999;
    //手机号无效
    const CODE_MOBILE_INVALID = 2001;
    //单设备验证码发送次数超限
    const CODE_SMS_OVER_LIMIT = 2002;
    //单手机号验证码发送时隔短
    const CODE_SMS_INTERVAL_TOO_SHORT = 2003;
    //验证码无效
    const CODE_SMS_CODE_ERR = 2004;
    //TOKEN
    const CODE_TOKEN_INVALID = 2005;
    //expire mem
    const CODE_EXPIRE_MEM = 2006;
    //order 
    const CODE_PARAM_ERR = 2007;
    //mobile 
    const CODE_MOBILE_EXIST = 2008;
    //withdraw
    const CODE_WITHDRAW_ERR = 2009;
    //giftcoin
    const CODE_GIFTCOIN_REPEAT = 2010;

    //game succ
    const CODE_GAME_SUCC = 0;
    //game verifycode error
    const CODE_GAME_VERIFY_ERR = 3001;
    //gtoken error
    const CODE_GAME_TOKEN_ERR = 3002;
    //game username err
    const CODE_GAME_USERNAME_ERR = 3003;
    //game cost faild
    const CODE_GAME_COST_FAILD = 3004;
    //game order repeat
    const CODE_GAME_ORDER_REPEAT = 3005;
    //game lock
    const CODE_GAME_LOCK_FAILD = 3006;
    //game release
    const CODE_GAME_RELEASE_FAILD = 3007;

    public function index()
    {
        header("php-serv-id: " . gethostname());

        $s      = I("post.r", "", "trim");
        $data   = array();
        if (!empty($s))
        {
            G('begin');
            $decode = $this->decode($s, "XSiOrq6+");
            $data = json_decode($decode, TRUE);
            G('end');
            $decrypt   = G('begin', 'end');
            header("decrypt-time: " . $decrypt);
            $encode = $this->getValue($data, "rt", "authcode", "trim");
            $action = $this->getValue($data, 'req', "index", "trim");
        } else {
            $action = I("request.req", "index", "trim");
        }
        $head = get_headers_info();

        if ($action !== 'index')
        {
            $api = sprintf("%s\\Api%sController", __NAMESPACE__, ucfirst($action));
            if (class_exists($api))
            {
                G('begin');
                $apiObj = new $api();
                if (!empty($data)) {
                    $data['req'] = $action;
                    $result = $apiObj->getDecryptData($data);
                } else {
                    $result = $apiObj->getData();
                }
                G('end');
                $exec   = G('begin', 'end');

                header("exec-time: " . $exec);

                //如果只返回状态码，则直接输出json，默认返回 '["errno":200]'
                if(is_array($result) && count($result) == 1)
                    $encode = 'json';

                echo $this->response($result, $encode, $head, $data);
                exit;
            }
        }
    }
    
    function response($result, $encode="json", $head, $data = null)
    {
        $result = json_encode($result, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        if($encode == "authcode")
        {
            if (isset($data) && !empty($data)) {
                $channel = $this->getValue($data, "channel", "", "trim");
                $key = empty($channel)? 'enjoynut': $channel;
            } else {
                $key = empty($head["channel"]) ? 'enjoynut' : $head["channel"];
            }

            $data = ["key"=>md5($key), "data"=>""];
            $data["data"] = authcode($result, 'ENCODE', $key);

            $result = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }


        return $result;
    }

    static function getErrMsg($code)
    {
        static $msg = [
            self::CODE_GAME_SUCC => "成功",
            self::CODE_GAME_VERIFY_ERR => "验证失败",
            self::CODE_GAME_TOKEN_ERR => "token值无效,用户不存在",
            self::CODE_GAME_USERNAME_ERR => "用户名不存在",
            self::CODE_GAME_COST_FAILD => "扣除失败，余额不足",
            self::CODE_GAME_ORDER_REPEAT => "订单号重复",
            self::CODE_GAME_LOCK_FAILD => "锁定用户失败",
            self::CODE_GAME_RELEASE_FAILD => "解锁用户失败",
            self::CODE_SERVER_ERR => "服务器处理错误",
        ];

        return $msg[$code];
    }
}
