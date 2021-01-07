<?php

namespace Admin\Controller;
use Admin\Model\WithdrawLogModel;
use Admin\Model\UsersModel;
use Admin\Model\CoinLogModel;

use Admin\Controller\SystemController;

/**
 * Class WithdrawLogController
 * @package Admin\Controller
 */
class WithdrawLogController extends SystemController
{
    public $model = "withdraw_log";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['contact']))
        {
            $map['contact'] = ['like' => '%' . $_search['contact'] . '%'];
        }
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
        if (isset($_search['alipay']))
        {
            $map['alipay'] = $_search['alipay'];
        }
        if (isset($_search['start_day']) && isset($_search['end_day']))
        {
            $map['create_at'] = [
                ['egt', strtotime($_search['start_day'] . '00:00:00')],
                ['elt', strtotime($_search['end_day'] . '23:59:59')],
                'and'
            ];
        }
        $map['status'] = WithdrawLogModel::STATUS_APPEND;
    }

    public function _before()
    {
        $this->assign('status', D($this->model)->status);
        $this->assign('lock', D('Admin/Users')->lock);
    }

    public function _before_update()
    { 
        $uid = $_POST['uid'];
        switch ($_POST['status']) {
            case WithdrawLogModel::STATUS_APPEND:
                $this->error("状态未改变");
                break;
            case WithdrawLogModel::STATUS_SUCC:
                // if (empty($_POST['pay_ali_or']))
                // {
                //     $this->error("请填写ali退款订单号");
                // }
                break;
            case WithdrawLogModel::STATUS_APPEND_FAILD:
                //$_POST['pay_ali_or'] = "";
                $lock = D('Admin/Users')->where(['id'=>$uid])->getField('lock');
                if ($lock == UsersModel::LOCK_GAMECOIN_ON)
                {
                    $this->error("该账户游戏币已锁定，请稍后重试");
                }
                D('Admin/Users')->where(['id'=>$uid])->save(['lock'=>UsersModel::LOCK_GAMECOIN_ON]);
                D('Admin/Users')->setGameLockTimeout($_POST['uid']);
                $user = D('Admin/Users')->where(['id'=>$uid])->find();
                $gamecoin = $user['gamecoin'] + $_POST['gamecoin'];
                $cost = $user['cost'] + $_POST['receipt_amount'];
                D('Admin/Users')->where(['id'=>$uid])->save(['gamecoin'=>$gamecoin, 'cost'=>$cost]);
                D('Admin/Users')->where(['id'=>$_POST['uid']])->save(['lock'=>UsersModel::LOCK_GAMECOIN_OFF]);
                D('Admin/Users')->delGameLockTimeout($_POST['uid']);
                break;    
            default:
                $this->error("不存在该状态");
                break;
        }
    }

    public function _after_update()
    {
        try {
            $count = D('Admin/CoinLog')->where(['orno'=>$_POST['orno']])->count();
            if ($count > 0)
            {
                 D('Admin/CoinLog')->where(['orno'=>$_POST['orno']])->save(['status'=>$_POST['status']]);
             } else {
                $coinlog = [
                    'uid' => $_POST['uid'],
                    'orno' => $_POST['orno'],
                    'amount' => $_POST['receipt_amount'],
                    'status' => $_POST['status'],
                    'type' => CoinLogModel::TYPE_WITHDRAW,
                    'create_at' => time(),
                    'update_at' => time(),
                ];
                D('Admin/CoinLog')->add($coinlog);
             }
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
            $this->error($e->getMessage());
        }
    }
}