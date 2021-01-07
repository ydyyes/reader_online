<?php
/**
 * User:Xxx
 */
namespace Server\Controller;


use Admin\Model\OrderModel;
use Common\Controller\Datasource;
use Pay\Controller\PayController;
use Think\Exception;
use Think\Log;
use Think\Think;

class OrderServerController extends BaseServerController
{
    public function createOrder($user_info,$product_info){

       try {
           M()->startTrans();
           $product_model = D('Admin/Product');
           $order['order_sn'] = self::createOrderSn();
           $order['u_id'] = $user_info['id'];
           $order['total_price'] = $product_info['price'];
           $order['pay_price'] = $product_info['discount_price'];
           $order['order_type'] = $product_model->type[$product_info['type']];
           $order['note'] = $product_info['product_name'];
           $order['status'] = '0';
           $order['create_time'] = time();
           $order['update_time'] = time();

           $order_model = D('Admin/Order');

           $res1 = $order_model->add($order);

           $order_item['order_id'] = $res1;
           $order_item['u_id'] = $user_info['id'];
           $order_item['quantity'] = 1;
           $order_item['price'] = $product_info['price'];
           $order_item['discount_price'] = $product_info['discount_price'];
           $order_item['p_id'] = $product_info['id'];
           $order_item['p_name'] = $product_info['product_name'];
           $order_item['p_time'] = $product_info['exchange_time'];
           $order_item['p_type'] = $product_model->type[$product_info['type']]?:'未知';
           $order_item['p_gold'] = $product_info['send_gold'];
           $order_item['create_time'] = time();
           $order_item['update_time'] = time();

           $order_item_model = D('Admin/OrderItem');
           $res2 = $order_item_model->add($order_item);

           $res = false;
           if ($res1 && $res2) {
               $pay_set = (new PayController());

               $pay_set->setParameter('app_id', C('app_id'));
               $pay_set->setParameter('merchant_id', C('merchant_id'));
               $pay_set->setParameter('power_id', C('power_id'));
               $pay_set->setParameter('merchant_order_no', $order['order_sn']);
               $pay_set->setParameter('order_money', (string)($product_info['discount_price'] * 100));
               $pay_set->setParameter('order_name', $order['note']);
               $pay_set->setParameter('req_ip', $_SERVER['REMOTE_ADDR']);
               $pay_set->setParameter('notify_url', C('notify_url'));
               $pay_set->setParameter('scene', '2');
               $pay_set->setParameter('interface_version', '1.0');
               $pay_set->setParameter('pay_range', '1');
               $pay_set->setParameter('order_desc', $order['note']);
               $info = $pay_set->getPrePayInfo();

               if(!is_array($info)){
                   throw new \Exception('order_create '.$info);
               }

               $res = $info;
               M()->commit();

           }else{
               throw new \Exception('order-create: res1 || res2 not created');
           }
       }catch (\Exception $e){

            M()->rollback();
            Log::write($e->getMessage(),'order');
       }

        return $res;

    }


    public function orderSuccess($order_sn , $parm ,$order_info){

        try {
            M()->startTrans();
            $order_model = D('Admin/Order');
            $order = $order_model->where(['order_sn' => $order_sn])->save($parm);

            if(!$order){
                throw  new \Exception('order not save','pay-callback');
            }
            $user_model = D('Admin/Users');
            $u_info = $user_model ->getUserInfoById($order_info['u_id']);

            if(!$u_info){
                   throw  new \Exception('user no find');
            }

            $is_expire = $user_model->getVipData($u_info['expire']);

           $order_item_info =  M('')->table('xs_order_item')
                ->where(['order_id' => $order_info['id']])
                ->find();

            $num = $order_item_info['p_time'] * 24 * 3600;
            if ($is_expire) {
                $expire = $u_info['expire'] + $num;
            } else {
                $expire = time() + $num;
            }
            $gold = $u_info['gold'] + $order_item_info['p_gold'];
            $res = $user_model
                ->where(['id' => $order_info['u_id']])
                ->save(['expire' => $expire,
                        'gold'   => $gold,
                        'utid'   => 3
                    ]);

            if ($res) {
                $redis = Datasource::getRedis('instance1');
                $list = $redis->hgetall($u_info['uni_id']);
                foreach ($list as $k => $v) {
                    if ($redis->hget($k, 'uni_id')) {
                        $redis->hset($k,'expire',$expire);
                        $redis->hset($k,'gold',  $gold);
                    }
                }

                //设置首次订单限制
                $redis->hset(OrderModel::firstOrderCacheKey(),$u_info['uni_id'],$order_sn);


            if($order_item_info['p_gold'] != 0) {
                $glod_log_model = D('Admin/GoldLog');
                $gold_add['uid'] = $u_info['id'];
                $gold_add['name'] = $order_item_info['p_name'];
                $gold_add['num'] = $order_item_info['p_gold'];
                $gold_add['create_time'] = time();

                $gold_add['describe'] = sprintf($order_item_info['p_name'], '充值赠送%s', $order_item_info['gold'] . '金币');

                //记录进金币日志表
                $glod_log_model->add($gold_add);
            }

            }else{
                throw  new \Exception('user not save');
            }



            M()->commit();
            $res = true;


        }catch(\Exception $e){
                $res = false;
                M()->rollback();
                Log::write($e->getMessage(),'pay-callback');
        }

        return $res;
    }

}