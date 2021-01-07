<?php

namespace Admin\Controller\Xs;

use Admin\Controller\SystemController;

/**
 * Class XsRecommendController
 * @package Admin\Controller
 */
class XsRecommendController extends SystemController
{
    public $model = "recommend";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['title']))
        {
            $nids = D('Admin/Novels')->where(['title' => ['like', '%'.$_search['title'].'%']])->getField('id', true);
            if (!empty($nids))
            {
                $map['nid'] = ['IN', $nids];
            } else {
                $map['id'] = 0;
            }
        }
    }


    public function _before()
    {
        $channels = D('Admin/SysChannel')->getField('id, name', true);
        $this->assign('channels', $channels);
    }

    public function _before_insert()
    {
        $this->check();
        $res = D($this->model)->where(['nid'=>$_POST['nid']])->find();
        if(!empty($res))
        {
            $status = D($this->model)->status;
            $this->error('该项已经存在,状态：' . $status[$res['status']]);
        }
    }

    public function _before_update()
    {
        $this->check();
    }

    public function check()
    {
        if (empty($_POST['novel_nid']))
        {
            $this->error('小说ID必填');
        }
        $novel = D('Admin/Novels')->where(['id'=>$_POST['novel_nid']])->count();
        if (empty($novel))
        {
            $this->error('该小说不存在，请重新输入ID');
        }
        $_POST['nid'] = $_POST['novel_nid'];
        unset($_POST['novel_nid']);
        if (empty($_POST['chn_id']))
        {
            $this->error('渠道必选');
        }
        $_POST['chn_id'] = ',' . trim(implode(',', $_POST['chn_id']), ',') . ',';
    }

    public function getNovels()
    {
        $nid = I('request.keyword', '*', 'trim');
        $data = D('Admin/Novels')->where(['id'=>$nid])->field('id, title, author')->select();
        $return = [];
        if (!empty($data))
        {
            foreach ($data as $val)
            {
                $return[] = ["id"=>$val['id'], "name"=>$val['id'] . ": " . $val['title'] . "--" . $val['author']];

                if(count($return) > 30)
                {
                    echo json_encode($return);
                    return;
                }
            }
        }
        echo json_encode($return);
    }
}