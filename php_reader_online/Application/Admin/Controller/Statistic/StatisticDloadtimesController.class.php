<?php

namespace Admin\Controller\Statistic;

use Admin\Controller\SystemController;

/**
 * Class XsStatisticDloadtimesController
 * @package Admin\Controller
 */
class StatisticDloadtimesController extends SystemController
{
    public $model = "statistic_dloadtimes";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['novel']))
        {
            $nids = D('Admin/Novels')->where(['title'=>['like', '%'.$_search['novel'] . '%']])->getField('id', true);
            if (!empty($nids))
            {
            	$map['nid'] = ['IN', $nids];
            } else {
            	$map['nid'] = 0;
            }
        }
        if (isset($_search['nid']))
        {
        	$map['nid'] = $_search['nid'];
        }
        if (isset($_search['chn_id']))
        {
        	$map['chn_id'] = $_search['chn_id'];
        }
    }

    public function _before_index()
    {
    	$channels = D('Admin/SysChannel')->getField('id,name', true);
    	$this->assign('channels', $channels);
    }
}