<?php

namespace Admin\Controller\Statistic;

use Admin\Controller\SystemController;

/**
 * Class XsStatisticChaptersController
 * @package Admin\Controller
 */
class StatisticChaptersController extends SystemController
{
    public $model = "statistic_chapters";

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
    }
}