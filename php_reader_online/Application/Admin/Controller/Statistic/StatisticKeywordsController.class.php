<?php

namespace Admin\Controller\Statistic;

use Admin\Controller\SystemController;

/**
 * Class XsStatisticKeywordsController
 * @package Admin\Controller
 */
class StatisticKeywordsController extends SystemController
{
	protected $_tpl_index = "Index";
	protected $_tpl_search = "Search";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['keyword']))
        {
        	$map['keyword'] = ['like' => '%' . $_search['keyword'] . '%'];
        }
    }

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

        if (isset($post['keyword']) && !empty($post['keyword']))
        {
            $post['keyword'] = (string)$post['keyword'];
            $where['keyword'] = $post['keyword'];
        }

        $model = D('Admin/StatisticKeywords');
        $all = $model->where($where)->select();
        foreach ($all as $val)
        {
            $list[$val['keyword']]['count'] += $val['count'];
        }

        $this->assign("post", $post);
        $this->assign("list", $list);
        $this->display($this->_tpl_search);
        exit;
    }
}