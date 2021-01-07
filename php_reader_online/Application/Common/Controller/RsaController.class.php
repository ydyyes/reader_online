<?php
/**
 * User:Xxx
 */

namespace Common\Controller;


class RsaController
{

    public $pi_key;
    public $pu_key;




    public function __construct()
    {
        $public_key = file_get_contents(CONF_PATH.'public_key');

        $public_pem = chunk_split($public_key,64,"\n");//转换为pem格式的公钥
        $public_pem = rtrim($public_pem);
        $public_pem = "-----BEGIN PUBLIC KEY-----\n".$public_pem."\n-----END PUBLIC KEY-----\n";
        $public_source = openssl_pkey_get_public($public_pem);
        if(!$public_source){
                die('资源错误');
        }else{
            $this->pu_key = $public_source;
        }
        $private_key = file_get_contents(CONF_PATH.'private_key');
        $private_pem = chunk_split($private_key,64,"\n");//转换为pem格式的公钥
        $private_pem = rtrim($private_pem);
        $private_pem = "-----BEGIN PRIVATE KEY-----\n".$private_pem."\n-----END PRIVATE KEY-----\n";
        $private_source = openssl_pkey_get_private($private_pem);
        if(!$private_source){
            die('资源错误2');
        }else{
            $this->pi_key = $private_source;
        }

    }

    public function PrivateEncrypt($data){
        // openssl_private_encrypt($data,$encrypted,$this->pi_key);
        $crypto = '';
        foreach (str_split($data, 117) as $chunk) {
            openssl_private_encrypt($chunk, $encryptData, $this->pi_key);
            $crypto .= $encryptData;
        }
        $encrypted = $this->urlsafe_b64encode($crypto);//加密后的内容通常含有特殊字符，需要编码转换下，在网络间通过url传输时要注意base64编码是否是url安全的
        return $encrypted;
    }

    function urlsafe_b64encode($string) {
        $data = base64_encode($string);
        $data = str_replace(array('+','/','='),array('-','_',''),$data);
        return $data;
    }


    function urlsafe_b64decode($string) {
        $data = str_replace(array('-','_'),array('+','/'),$string);
        $mod4 = strlen($data) % 4;
        if ($mod4) {
            $data .= substr('====', $mod4);
        }
        return base64_decode($data);
    }

    public function PublicDecrypt($encrypted){
        // $encrypted = $this->urlsafe_b64decode($encrypted);
        $crypto = '';
        foreach (str_split($this->urlsafe_b64decode($encrypted), 117) as $chunk) {
            openssl_public_decrypt($chunk, $decryptData, $this->pu_key);
            $crypto .= $decryptData;
        }
        //openssl_public_decrypt($encrypted,$decrypted,$this->pu_key);//私钥加密的内容通过公钥可用解密出来
        return $crypto;
    }


    public function PublicEncrypt($data){

        //openssl_public_encrypt($data,$encrypted,$this->pu_key);//公钥加密
        $crypto = '';
        foreach (str_split($data, 117) as $chunk) {
            $aa = openssl_public_encrypt($chunk, $encryptData, $this->pu_key);
            $crypto .= $encryptData;
        }
        $encrypted = base64_encode($crypto);
        return $encrypted;
    }


    public function PrivateDecrypt($encrypted)
    {

        $crypto = '';
        foreach (str_split(base64_decode($encrypted), 128) as $chunk) {
            openssl_private_decrypt($chunk, $decryptData, $this->pi_key);

            $crypto .= $decryptData;
        }
        //$encrypted = $this->urlsafe_b64decode($encrypted);
        //openssl_private_decrypt($encrypted,$decrypted,$this->pi_key);
        return $crypto;
    }



}