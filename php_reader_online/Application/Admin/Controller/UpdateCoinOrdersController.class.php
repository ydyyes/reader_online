<?php

namespace Admin\Controller;

use Admin\Controller\SystemController;

/**
 * Class CoinLogController
 * @package Admin\Controller
 */
class UpdateCoinOrdersController extends SystemController
{
    public $model = "update_coin_orders";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['username']))
        {
            $uid = D('Admin/Users')->where(['username'=>$_search['username']])->getField('id');
            if (!empty($uid))
            {
                $map['uid'] = $uid;
            } else {
                $map['uid'] = 0;
            }
        }
        if (isset($_search['guser']))
        {
            $map['guser'] = $_search['guser'];
        }
        if (isset($_search['serial']))
        {
            $map['serial'] = $_search['serial'];
        }
    }
}