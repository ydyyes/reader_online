<?php
/**
 * User:Xxx
 */

namespace Vend\Controller;


use Pay\Controller\BaseController;
use Server\Controller\OrderServerController;
use Think\Controller;
use Think\Log;

class PayCallbackController extends BaseController
{
    public function save(){

        $data_json = file_get_contents("php://input");
        Log::record($data_json,'pay-callback',1);
        Log::save('',DATA_HOME.'Pay'.DIRECTORY_SEPARATOR. date('Y_m_d') . '.log');
        $data = json_decode($data_json,true);
        if($data['app_id'] != C('app_id') || $data['power_id'] != C('power_id')){
            die('fail');
        }

        if( !isset($data['sign']) ){
            die('fail');
        }

        if( !$this->checkSign( $data ) ){
            die('fail');
        }

        $order_sn = $data['merchant_order_no'];

       $order_model =  D('Admin/Order');
       $order_info  =  $order_model -> where(['order_sn' => $order_sn ])->find();

         if ( intval( strval( $order_info['pay_price'] * 100 ) ) != $data['order_money']) { //单位为分
             die('fail');
        }


        if ($order_info['status'] == 2 ) {
            die('success');
        }

        if($data['pay_status'] != 2){
            die('fail');
        }


        $parm = ['pay_sn' => $data['order_no'],
                 'status' => $data['pay_status'],
                 'pay_time' => strtotime($data['pay_finished_time'])
            ];

        $res = (new OrderServerController())->orderSuccess($order_sn,$parm,$order_info);

        if(!$res){
            die('fail');
        }

        $parm_callback = ['order_id' => $order_info['id'],
                'pay_data' => $data_json,
                'create_time' => time(),
                'update_time' => time()];
        M('')->table('xs_order_callback_data')->add($parm_callback);

        die('success');

    }

}