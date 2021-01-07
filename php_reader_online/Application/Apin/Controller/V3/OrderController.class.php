<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V3;


use Admin\Model\ProductModel;
use Apin\Controller\V1\BaseController;
use Common\Controller\Datasource;
use Common\Validate\IdMustValidate;
use Pay\Controller\PayController;
use Server\Controller\OrderServerController;

class OrderController extends BaseController
{
    public function create()
    {
        (new IdMustValidate())->gocheck($this->parm['id']);
        //如果token存在证明有登陆账户
        if (!empty($this->parm['token'])) {
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        //查询商品是否在架
        $product_model = D('Admin/Product');
        $where['id'] = $this->parm['id'];
        $where['status'] = ProductModel::STATUS_ON;
        $product_info = $product_model->where($where)->find();

        if (!$product_info) {
            $this->returnResult(400119);
        }

        //首次充值套餐判断
        if ($product_info['type'] == ProductModel::FISTER) {
            $order_model = D('Admin/Order');
            $order_where['u_id'] = $this->userinfo['id'];
            $order_where['status'] = ['not in', [0,7]];
            $order_info = $order_model->where($order_where)->find();
            if ($order_info) {
                $this->returnResult(600102);
            }
        }
        $redis = Datasource::getRedis('instance1');

        if ($redis->set(ProductModel::ProductOrderCacheKeyLock($this->userinfo['uni_id']), 1, ['nx', 'ex' => 3])) {
            $res = (new OrderServerController())->createOrder($this->userinfo, $product_info);
        }else{
            $this->returnResult(400114);
        }


        if (!is_array($res)) {
            $this->returnResult(600101);
        }

        $this->returnResult(200, '', $res);

    }

    public function read(){
        $order_model = D('Admin/Order');

        //如果token存在证明有登陆账户
        if (!empty($this->parm['token'])) {
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        $page =(int)$this->parm['page']?:1;
        $size =(int)$this->parm['size']?:6;

        $info = $order_model -> getOrder($page,$size,$this->userinfo['id']);

        return $this->returnResult(200,'',$info);
    }

    public function find()
    {

        if (empty($this->parm['order_sn'])) {
            $this->returnResult(400100);
        }

        $order_sn = $this->parm['order_sn'];
        $order_model = D('Admin/Order');
        $order_info = $order_model
            ->where(['order_sn' => $order_sn])
            ->find();

        if ($order_info['status'] == 2) {
            $this->returnResult(201);

        }else{

            $pay_set = (new PayController());
            $info = $pay_set->queryOrderInfo($order_sn);

            if(!$info || $info['code'] != '0000'){
                $this->returnResult(600103);
            }

            $this->returnResult(200,query_order_msg($info['pay_status']));


        }

    }
}