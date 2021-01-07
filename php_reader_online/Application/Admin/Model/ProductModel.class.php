<?php
/**
 * User:Xxx
 */

namespace Admin\Model;


use Common\Controller\Datasource;

class ProductModel extends SystemModel
{
    protected $trueTableName = 'xs_product';


    public $_auto		=	array(
        array('create_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_UPDATE,'function'),
    );

    const  FISTER   = 1;
    const  NORMAL   = 2;
    const  DISCOUNT = 3;

    public $type = [
        self::FISTER    => '首次套餐',
        self::NORMAL    => '正常套餐',
        self::DISCOUNT  => '折扣套餐'
    ];


    const STATUS_DEL = -1;
    const STATUS_OFF = 0;
    const STATUS_ON = 1;


    public $status = [
        self::STATUS_ON    => '上架',
        self::STATUS_OFF   => '下架',
    ];




    static public function ProductOrderCacheKeyLock($uni_id){

        return  C('REDIS_PREFIX').'product_order_lock_'.$uni_id;
    }


    /**
     *  获取分类数据
     */
    public function getProductList($uni_id){

        $redis = Datasource::getRedis('instance1');
        $product_list = $redis -> get(self::ProductListCacheKey());
        if(!$product_list){
            $where['status'] = self::STATUS_ON;
            $product_list = self::where($where)->select();

            if($product_list){
                S(self::ProductListCacheKey(),serialize($product_list));
            }

        }else{
            $product_list = unserialize($product_list);
        }
       $data_list = [];
        if($redis->hget(OrderModel::firstOrderCacheKey(),$uni_id)){

              foreach ($product_list as $key => $val){

                  if($val['type'] == self::FISTER ){

                        unset($product_list[$key]);
                  }else{
                      array_push($data_list,$val);
                  }

              }
        }else{
            $data_list = $product_list?:[];
        }


        return $data_list;
    }

    public function clearProductList(){
        $redis = Datasource::getRedis('instance1');
        $redis->del(self::ProductListCacheKey());
    }

    private function ProductListCacheKey(){
        return  C('REDIS_PREFIX').'prodcut_list';
    }

}