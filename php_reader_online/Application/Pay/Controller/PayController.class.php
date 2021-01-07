<?php
/**
 * User:Xxx
 */

namespace Pay\Controller;


use Common\Controller\HttpSendController;
use Common\Controller\RsaController;

class PayController extends BaseController
{
    public function getPrePayInfo(){

        $this->params["sign"] = $this->MakeSign($this->params);//签名


        //加密
        $post_data = (new RsaController())->PublicEncrypt(json_encode($this->params));
        $send_data['app_id'] = C('app_id');
        $send_data['order_info'] = $post_data;
        $send_data = json_encode($send_data);

        $info = HttpSendController::sendPost(C('pay_url'),$send_data);
        $decode_info = (new RsaController())->PrivateDecrypt($info);
        $decode_info = json_decode($decode_info,true);
        if((!$decode_info) || (!isset($decode_info['code']))){
            return 500102;
        }

        $sign = $this->checkSign($decode_info);

        if(!$sign){
            return 500103;
        }



        if($decode_info['code'] != '0000'){
            return $decode_info['msg'];
        }

        //新的返回值
        $res_info['code'] = $decode_info['code'];
        $res_info['merchant_order_no'] = $decode_info['merchant_order_no'];
        $res_info['pay_url'] = $decode_info['pay_url'];
        $res_info['sign'] = $this->MakeSign($res_info,1);

        return $res_info;


    }

    public function queryOrderInfo($order_sn){


        self::setParameter('app_id', C('app_id'));
        self::setParameter('merchant_order_no',$order_sn);
        self::setParameter('merchant_id', C('merchant_id'));
        self::setParameter('interface_version', '1.0');
        self::setParameter('service','order_query');
        $this->params["sign"] = $this->MakeSign($this->params);//签名

        $post_data = (new RsaController())->PublicEncrypt(json_encode($this->params));
        $send_data['app_id'] = C('app_id');
        $send_data['order_info'] = $post_data;
        $send_data = json_encode($send_data);

        $info = HttpSendController::sendPost(C('query_order_url'),$send_data);

        $decode_info = (new RsaController())->PrivateDecrypt($info);
        $decode_info = json_decode($decode_info,true);

        return $decode_info;

    }

}