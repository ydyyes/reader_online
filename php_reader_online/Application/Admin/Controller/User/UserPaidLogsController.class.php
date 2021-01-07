<?php
/**
 * User:Xxx
 */

namespace Admin\Controller\User;


use Admin\Controller\SystemController;

class UserPaidLogsController extends  SystemController
{
    public $model = "order";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['u_id']))
        {
            $map['u_id'] = $_search['u_id'];
        }
        if (isset($_search['note']))
        {
            $map['note'] = ['like','%'.$_search['note'].'%'];
        }
        if (isset($_search['order_sn']))
        {
            $map['order_sn'] = $_search['order_sn'];
        }

        if (isset($_search['pay_sn']))
        {
            $map['pay_sn'] = $_search['pay_sn'];
        }

        if(isset($_search['start_time']) && isset($_search['end_time']) ){
            $start_time = strtotime($_search['start_time']);
            $end_time   = strtotime($_search['end_time']);
            if($end_time - $start_time > 0 ){
                $map['create_time'] = ['between',[$start_time,$end_time]];

            }

        }

    }

}