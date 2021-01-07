<?php
/**
 * User:Xxx
 */

namespace Common\Controller;


use Think\Controller;
use Think\Think;

class HttpSendController extends Controller
{


    public static function sendGet($url, $param =[]) {

        return self::curl($url, $param,"get");
    }

    public static function sendPost($url, $param,$extra = [] ) {

        return self::curl($url, $param,"post");
    }


    protected static function curl($url, $param, $method = 'post')
    {

        try {
            $time = time();
            // 初始化
            $curl = curl_init();
            curl_setopt($curl, CURLOPT_URL, $url);
            curl_setopt($curl, CURLOPT_HEADER, 0);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($curl, CURLOPT_CERTINFO, true);
            curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
            //curl_setopt($curl, CURLOPT_VERBOSE, true); //打印日志

            curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);//函数中加入下面这条语句


            curl_setopt($curl, CURLOPT_TIMEOUT, 5);


            if (array_key_exists("HTTP_USER_AGENT", $_SERVER)) {
                curl_setopt($curl, CURLOPT_USERAGENT, $_SERVER['HTTP_USER_AGENT']);
            }

            // post处理
            if ($method == 'post') {
                curl_setopt($curl, CURLOPT_POST, TRUE);
                if (is_array($param)) {
                    $param = http_build_query($param);
                }

                curl_setopt($curl, CURLOPT_POSTFIELDS, $param);
            } else {
                curl_setopt($curl, CURLOPT_POST, FALSE);
            }

            // 执行输出
            $info = curl_exec($curl);

            //log
            $_errno = curl_errno($curl);
            if ($_errno) {
                $_error = curl_error($curl);
                throw new \Exception($_error,$_errno);
            }
            curl_close($curl);


        }catch (\Exception $e){
            $info = false;
          \Think\Log::write('curl:[post]'.$_errno.': '.$_error);

        }
        return $info;
    }


}