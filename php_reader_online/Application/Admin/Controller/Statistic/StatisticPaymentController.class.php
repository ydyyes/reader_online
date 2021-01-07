<?php

namespace Admin\Controller\Statistic;

use Admin\Controller\SystemController;

/**
 * Class XsStatisticChaptersController
 * @package Admin\Controller
 */
class StatisticPaymentController extends SystemController
{
    protected $_tpl_index = 'Index';
    protected $_tpl_search = 'Search';

    public function index()
    {
        $channels = D('Admin/SysChannel')->getField('name', true);
        $this->assign('channels', array_combine($channels, $channels));
        $this->display($this->_tpl_index);
    }

    function search()
    {
        $post = I("post.");

        $where = $list = [];
        $today = date("Y-m-d");
        $post["start_day"] = $post["start_day"] > $today ? $today : $post["start_day"];
        $post["end_day"] = $post["end_day"] > $today ? $today : $post["end_day"];
        $where['day'] = [['egt', date('Ymd', strtotime($post['start_day']))], ['elt', date('Ymd', strtotime($post['end_day']))]];

        if (isset($post['channel']) && !empty($post['channel']))
        {
            $post['channel'] = (string)$post['channel'];
            $where['channel'] = $post['channel'];
        }

        $model = D('Admin/StatisticPayment');
        $all = $model->where($where)->select();
        foreach ($all as $val)
        {
            $list[$val['channel']]['persons'] += $val['persons'];
            $list[$val['channel']]['persons_mon'] += $val['persons_mon'];
            $list[$val['channel']]['persons_hy'] += $val['persons_hy'];
            $list[$val['channel']]['persons_y'] += $val['persons_y'];
            $list[$val['channel']]['amount'] += $val['amount'];
        }

        $this->assign("post", $post);
        $this->assign("list", $list);
        $this->display($this->_tpl_search);
        exit;
    }
}