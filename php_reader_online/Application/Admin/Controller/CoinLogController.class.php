<?php

namespace Admin\Controller;
use Admin\Model\CoinLogModel;

use Admin\Controller\SystemController;

/**
 * Class CoinLogController
 * @package Admin\Controller
 */
class CoinLogController extends SystemController
{
    public $model = "coin_log";

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
        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
        if (isset($_search['type']))
        {
            $map['type'] = $_search['type'];
        }
        if (isset($_search['start_day']) && isset($_search['end_day']))
        {
            $map['create_at'] = [
                ['egt', strtotime($_search['start_day'] . '00:00:00')],
                ['elt', strtotime($_search['end_day'] . '23:59:59')],
                'and'
            ];
        }
    }

    public function _before()
    {
        $this->assign('status', D($this->model)->status);
        $this->assign('type', D($this->model)->type);
    }
}