<?php
/**
 * User:Xxx
 */

namespace Admin\Model;


class OrderModel extends SystemModel
{
    protected $trueTableName = 'xs_order';


    static public function firstOrderCacheKey(){

        return  C('REDIS_PREFIX').'first_order_all';
    }
    public function expire_order(){
        $exipre_time = time()-(15*60);
        $where['status'] = '0';
        $where['create_time'] = ['LT',$exipre_time];
        self::where($where)->save(['status' => '7']);
    }

    public function getOrder($page,$size,$u_id){
        $where['status'] = ['not in',[7,0]];

        $start = ($page-1)*$size;
        $where['u_id']  = $u_id;
        $info = self::where($where)->field('pay_price,status,create_time,note as name')
            ->order('create_time desc')
            ->limit($start,$size)
            ->select();
        if($info)
            $info = array_map('payStatus', $info);

        return $info;

    }


}