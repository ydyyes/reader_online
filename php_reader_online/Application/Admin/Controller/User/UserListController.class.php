<?php

namespace Admin\Controller\User;

use Admin\Controller\SystemController;
use Common\Controller\Datasource;
use Think\Db;

/**
 * Class UserListController
 * @package Admin\Controller
 */
class UserListController extends SystemController
{
    public $model = "users";

    public $days = [
            1 => "0",
            2 => "1-30",
            3 => "31-180",
            4 => "180以上"
        ];

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['id']))
        {
            $map['id'] = $_search['id'];
        }
        if (isset($_search['uni_id']))
        {
            $map['uni_id'] = $_search['uni_id'];
        }
        if (isset($_search['mobile']))
        {
            $map['mobile'] = $_search['mobile'];
        }
        if (isset($_search['utid']))
        {
            $map['utid'] = $_search['utid'];
        }
        if (isset($_search['devid']))
        {
            $map['devid'] = $_search['devid'];
        }
        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
        if (isset($_search['channel']))
        {
            $map['channel'] = $_search['channel'];
        }
        if (isset($_search['days']))
        {
            switch ($_search['days']) {
                case 1:
                    $map['expire'] = ['lt', time()];
                    break;
                case 2:
                    $map['expire'] = [['egt', time()], ['elt', strtotime("+30 days")]];
                    break;
                case 3:
                    $map['expire'] = [['gt', strtotime("+30 days")], ['elt', strtotime("180 days")]];
                    break;
                case 4:
                    $map['expire'] = ['gt', strtotime("+180 days")];
                    break;
            }
        }
    }

    //后台操作金币记录

    public function adminGoldLog(){

        $list = M()->table('xs_admin_gold_log')
            ->order('create_time desc')
            ->select();

        $this->assign('list',$list);
        $this->display();
    }




    public function editGold()
    {
        $id = I('id');
        $info = D($this->model)->where(['id' => $id ])->find();

        $this->assign('info',$info);
        $this->display();
    }

    public function saveGold()
    {
        $id = I('id');
        $gold = I('post.gold','','int');

        $info = D($this->model)->where(['id' => $id ])->find();
        if($minus = stristr($gold,'-')){


            if($info['gold'] - $gold < 0 ){
                $this->error('金币不足,无法执行操作');
            }else{
                $res = D($this->model)->where(['id'=>$id])->setInc('gold',$minus);
                self::saveCacheUserInfoGold($info['uni_id'],$minus);


            }

        }else{

           $res = D($this->model)->where(['id'=>$id])->setInc('gold',$gold);
           self::saveCacheUserInfoGold($info['uni_id'],$gold);
        }

        if(!$res) {

            $this->error('操作失败');
        }

        $gold_log['uid'] = $id;
        $gold_log['info'] = '金币操作数为'.$gold;
        $gold_log['create_time'] = time();
        $gold_log['operator'] = session('loginUserName');
        M()->table('xs_admin_gold_log')->add($gold_log);

        $this->assign('jumpUrl', cookie('_currentUrl_'));
        $this->success('操作成功!', 'closeCurrent');
     }

    public function _before()
    {

        $user_model = D('Admin/Users');
        $this->assign('type',$user_model->userTypes);
        $this->assign('days', $this->days);
        $this->assign('status', D($this->model)->status);
        $this->assign('lock', D($this->model)->lock);
    }

    public function saveCacheUserInfoGold($uni_id,$gold){
        $redis = Datasource::getRedis('instance1');
        $list = $redis->hgetall($uni_id);
        foreach ($list as $k => $v) {
            if ($redis->hget($k, 'uni_id')) {
                $redis->hincrby($k, 'gold', $gold);
            }
        }
    }
}