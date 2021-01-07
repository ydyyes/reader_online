<?php
namespace Api\Controller;

use Think\Controller;

abstract class BaseController extends Controller
{
    /**
     * 客户端接口
     *
     * @return array
     */
    public function getData()
    {
        return array();
    }

    /**
     * 获取输入流信息
     *
     * @param  bool   $toArray 是否转化成数组
     * @param  bool   $authCode 是否加密
     * @return string
     */
    protected function getPostData($toArray=true, $authCode=false)
    {
        $postData = file_get_contents("php://input");
        if(!empty($postData))
        {
            $data = $authCode ? authcode($postData) : $postData;

            if($toArray)
                parse_str($data, $data);
        } else {
            //gpc
            $data = $_REQUEST;
        }


        return $data;
    }

    /**
     * 下载文件
     *
     * @param  string $filePath path
     * @return void
     */
    protected function download($filePath)
    {
        //下载文件需要用到的头
        Header("Content-type: application/octet-stream");
        Header("Accept-Ranges: bytes");
        Header("Accept-Length:".filesize($filePath));
        Header("Content-Disposition: attachment; filename=a.txt");
        readfile($filePath);
    }

    public function getValue($data, $key, $default = '', $filter = null)
    {
        if (array_key_exists($key, $data)) {
            $value = $data[$key];
            if (isset($filter)) {
                $value = $filter($value);
            }
        } else if (array_key_exists("common", $data) && array_key_exists($key, $data['common'])) {
            $value = $data['common'][$key];
            if (isset($filter)) {
                $value = $filter($value);
            }
        } else if (strpos($key, "/")) {
            $keys = explode("/", $key);
            $v = $data;
            $t = TRUE;
            for ($i=0; $i<count($keys)-1; $i++) {
                if (!empty($keys[$i]) && array_key_exists($keys[$i], $v)) {
                    $v = $v[$keys[$i]];
                } else {
                    $t = FALSE;
                    break;
                }
            }

            if ($t && !empty(end($keys)) && array_key_exists(end($keys), $v)) {
                $value = $v[end($keys)];
                if (isset($filter)) {
                    $value = $filter($value);
                }
            } else {
                $value = $default;
            }
        } else {
            $value = $default;
        }
        return $value;
    }

    protected function encode($data, $key)
    {
        $size = mcrypt_get_block_size(MCRYPT_DES, MCRYPT_MODE_CBC);
        $str = $this->pkcs5Pad($data, $size);
        $str = mcrypt_encrypt(MCRYPT_DES, $key, $str, MCRYPT_MODE_CBC, $key);
        return base64_encode($str);
    }

    protected function decode($data, $key)
    {
        $str = base64_decode($data);
        $str = mcrypt_decrypt(MCRYPT_DES, $key, $str, MCRYPT_MODE_CBC, $key);
        $str = $this->pkcs5Unpad($str);
        return $str;
    }

    protected function pkcs5Pad($data, $blocksize)
    {
        $pad = $blocksize - (strlen($data) % $blocksize);
        return $data.str_repeat(chr($pad), $pad);
    }

    protected function pkcs5Unpad($data)
    {
        $pad = ord($data {strlen($data) - 1});
        if ($pad > strlen($data)) {
            return false;
        }
        if (strspn($data, chr($pad), strlen($data) - $pad) != $pad) {
            return false;
        }
        return substr($data, 0, -1*$pad);
    }

    protected function logByMonth(array $data, $filename)
    {
        $dir = ATTACH_PATH . "log/" . date("Ym") . "/";
        if (!is_dir($dir))
        {
            mkdir($dir, 0777, true);
        }
        $data['time'] = date("Ymd\\TH:i:s+0800");
        file_put_contents($dir . date("Ymd") . $filename.".log", json_encode($data) . PHP_EOL, FILE_APPEND | LOCK_EX);
    }
}