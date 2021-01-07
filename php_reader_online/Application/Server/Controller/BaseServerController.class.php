<?php
/**
 * User:Xxx
 */

namespace Server\Controller;


use Admin\Model\OrderModel;

class BaseServerController
{
    public static function createOrderSn(){
        do{
            $sn =date('Ymd',time()).substr(md5(microtime(1).rand(0,9999999).'S@JAIU&$MN'),8);

        }while( (new OrderModel)->where(['order_sn' => $sn])->find() );

        return $sn;
    }

}