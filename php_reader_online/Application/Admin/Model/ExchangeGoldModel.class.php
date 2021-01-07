<?php
/**
 * User:Xxx
 */

namespace Admin\Model;


class ExchangeGoldModel extends SystemModel
{
    protected $trueTableName = 'xs_exchange_gold';
    public $_auto		=	array(
        array('create_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_UPDATE,'function'),
    );


    const  STATUS_ON  = 1;
    const  STATUS_OFF = 0;


    public $status = [
        self::STATUS_ON =>  '正常',
        self::STATUS_OFF => '禁用',
    ];
    const FREE_ADD = 1;

    public $type = [
        self::FREE_ADD => '免广告',
    ];

    /*
     * 获取数据
     */
    public function getData(){
         $data = S(self::exchangeGoldListKay());

         if(!$data) {
             $where['status'] = self::STATUS_ON;
             $data = self::where($where)
                 ->field('id,name,type,num,cost_gold,cover')
                 ->select();
             if ($data) {
                 $data = array_map('callbackImg', $data);
             }
             S(self::exchangeGoldListKay(), serialize($data));
         }else{
             $data = unserialize($data);
         }
       return $data;
    }

    public function ClearExchangeGoldListKay(){
          S(self::exchangeGoldListKay(),null);
    }


    public function exchangeGoldListKay(){
        return 'exchange_gold_list';
    }

    //

    public function getStatus($id){
        $where['id'] = $id;
        $where['status'] = self::STATUS_ON;
        $res = self::where($where)
            ->find();

        return $res;
    }


}