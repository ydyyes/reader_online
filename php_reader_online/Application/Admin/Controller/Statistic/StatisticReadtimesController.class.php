<?php

namespace Admin\Controller\Statistic;

use Admin\Controller\SystemController;

/**
 * Class XsStatisticReadtimesController
 * @package Admin\Controller
 */
class StatisticReadtimesController extends SystemController
{
    protected $_tpl_index = "Index";
    protected $_tpl_search = "Search";

    public function index()
    {
        $this->display($this->_tpl_index);
    }

    public function search()
    {
        $post = I("post.");

        $where = $list = [];
        $today = date("Y-m-d");
        $post["start_day"] = $post["start_day"] > $today ? $today : $post["start_day"];
        $post["end_day"] = $post["end_day"] > $today ? $today : $post["end_day"];
        $where['day'] = [['egt', date('Ymd', strtotime($post['start_day']))], ['elt', date('Ymd', strtotime($post['end_day']))]];

        $nids1 = $nids2 = [];
        if (isset($post['nid']) && !empty($post['nid']))
        {
            $count = D('Admin/Novels')->where(['id'=>$post['nid']])->count();
            if ($count > 0)
            {
                $nids1 = [$post['nid']];
            }
        }

        if (isset($post['title']) && !empty($post['title']))
        {
            $nids2 = D('Admin/Novels')->where(['title'=>['like', '%'.$post['title'] . '%']])->getField('id', true);
        }

        if (empty($nids1) || empty($nids2))
        {
            $nids = array_merge($nids1, $nids2);
        } else {
            $nids = array_intersect($nids1, $nids2);
        }

        if (!empty($nids))
        {
            $where['nid'] = ['IN', $nids];
        }
        
        $model = D('Admin/StatisticReadtimes');
        $all = $model->where($where)->select();
        foreach ($all as $val)
        {
            $list[$val['nid']]['count'] += $val['count'];
            $list[$val['nid']]['count_shelf'] += $val['count_shelf'];
        }

        if (!empty($list))
        {
            $novels = D('Admin/Novels')->where(['id'=>['IN', array_keys($list)]])->getField('id, title', true);
        }

        $this->assign("post", $post);
        $this->assign("list", $list);
        $this->assign('novels', empty($novels) ? [] : $novels);
        $this->display($this->_tpl_search);
        exit;
    }    
}