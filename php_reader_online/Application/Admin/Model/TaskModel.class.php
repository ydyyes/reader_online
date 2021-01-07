<?php
/**
 * author:liu.
 */

namespace Admin\Model;


class TaskModel extends SystemModel
{
    protected $trueTableName = 'xs_task';

    const  TASK_DAY  = 1;
    const  TASK_GOLD =2;

    public $_auto		=	array(
        array('create_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_UPDATE,'function'),
    );

    //每日签到
    const TASK_TYPE_SIGN  = 1;
    const TASK_TYPE_SHARE = 2;
    const TASK_TYPE_READER = 3;
    const TASK_TYPE_BIND       = 4;
    const TASK_TYPE_AD_BROWSE  = 5;
    const TASK_TYPE_READER_30  = 6;
    const TASK_TYPE_READER_60  = 7;
    const TASK_INVITATION      = 8;
    const TASK_INVITATION_T    = 9;

    //阅读时长
    const READER_120 = 120;
    const READER_60  = 60;
    const READER_30  = 30;


    public $task_type = [
        self::TASK_TYPE_SIGN   => '每日签到',
        self::TASK_TYPE_SHARE  => '分享奖励',
        self::TASK_TYPE_READER => '阅读120分钟奖励',
        self::TASK_TYPE_BIND   => '绑定手机号',
        self::TASK_TYPE_AD_BROWSE => '观看视频广告',
        self::TASK_TYPE_READER_30 => '阅读30分钟奖励',
        self::TASK_TYPE_READER_60 => '阅读60分钟奖励',
        self::TASK_INVITATION     => '邀请好友奖励',
        self::TASK_INVITATION_T   => '邀请3个人时的奖励'


    ];



    //金币奖励的记录
    public $task_type_gold = [
        self::TASK_TYPE_SIGN      => '连续签到%s天奖励%s',
        self::TASK_TYPE_SHARE     => '每日分享奖励%s',
        self::TASK_TYPE_READER    => '阅读120分钟奖励%s',
        self::TASK_TYPE_BIND      => '绑定手机号奖励%s',
        self::TASK_TYPE_READER_30 => '阅读30分钟奖励%s',
        self::TASK_TYPE_READER_60 => '阅读60分钟奖励%s',
        self::TASK_INVITATION     => '邀请好友奖励%s',
        self::TASK_INVITATION_T   => '达到邀请3个好友奖励%s',

    ];

    //邀请好友奖励的记录
    public $task_inviation = [
        'inviation'       => '邀请好友成功奖励%s',
        'inviation_pa'    => '兑换邀请码奖励%s',
        'inviation_t'    => '达到邀请3个好友奖励%s',

    ];

    //邀请人达到奖励
    const TASK_INVIATION_T_NUM = 3;


    //反射对应的方法
    public $task_function = [
        self::TASK_TYPE_SIGN   => 'signAward',
        self::TASK_TYPE_SHARE  => 'shareAward',
        self::TASK_TYPE_READER => 'readerAward',
        self::TASK_TYPE_BIND   => 'bindAward',
        self::TASK_TYPE_AD_BROWSE => 'browseAward',
        self::TASK_INVITATION     => 'invitationAward'

    ];



    public $type = [
        self::TASK_DAY => '奖励小时',
        self::TASK_GOLD => '奖励金币',
    ];

    const WAY_FIXATION = 1;
    const WAY_RAND = 2;

    public $way = [
        self::WAY_FIXATION => '固定',
        self::WAY_RAND     => '随机'
    ];


    const  STATUS_ON  = 1;
    const  STATUS_OFF = 0;


    public $status = [
        self::STATUS_ON =>  '正常',
        self::STATUS_OFF => '禁用',
    ];

    /**
     *  设置阅读时长缓存
     */
    public function getTaskReaderTimeCache($uid){

       $time = S(self::TaskReaderTimeCacheKey($uid));
       $time = $time?:'0';
       return $time;
    }

    public function SetTaskReaderTimeCache($uid,$time){
         S(self::TaskReaderTimeCacheKey($uid),$time,strtotime('tomorrow')-time());
    }

    public function TaskReaderTimeCacheKey($uid){
        return 'task_reader_time_'.$uid;
    }

    /*
     * 阅读奖励限制
     */

    public function checkReaderLimit($uid,$time){
        $limit = 1;


        if(S(self::ReaderLimitCacheKey($uid,$time)) < $limit){
            return true;
        }
        return false;

    }


    public function setReaderLimit($uid,$time){
        $res = S(self::ReaderLimitCacheKey($uid,$time));
        if(!$res){
            $res = 0;
        }
        $res++;
        S(self::ReaderLimitCacheKey($uid,$time),$res,strtotime('tomorrow')-time());


        return $res;

    }

    public function ReaderLimitCacheKey($uid,$time){
        return 'reader_limit_'.$uid.'_'.$time;
    }

    /*
     * 观看视频限制
     */
    public function CheckADBrowseLimit($uid){
         $limit = D('SysConfig')->getValue('AD_BROWSE_LIMIT') ?:5;

        if(S(self::ADBrowseLimitCacheKey($uid)) >= $limit){
           return true;
        }
            return false;

    }

    public function ADBrowseLimitCacheKey($uid){
        return 'ad_browse_limit_'.$uid;
    }

    public function setADBrowseLimit($uid){
        $res = S(self::ADBrowseLimitCacheKey($uid));
        if(!$res){
            $res = 0;
        }
        $res++;
        S(self::ADBrowseLimitCacheKey($uid),$res,strtotime('tomorrow')-time());
    }

    /*
     * 签到
     */
    public function getNowSignStatus($uid){

        $uid_sign_data = S(self::SignCacheKey($uid));
        $now =strtotime(date('Y-m-d'));
        $res = '0';
        if($uid_sign_data && ($now - explode('|',$uid_sign_data)['1'] == 0) ){
            $res = '1';
        }

        return $res;

    }


    /*
     * 签到
     */
    public function signDate($uid){
        $now =strtotime(date('Y-m-d'));
        $d_now =strtotime('+2 days',$now)-1;
        $expire = $d_now - $now;
        $uid_sign_data = S(self::SignCacheKey($uid));
        $num = 0;
        if(!$uid_sign_data){
            $num = 1;
            S(self::SignCacheKey($uid),$num.'|'.$now,$expire);
        }else{
            $uid_sign_data = explode('|',$uid_sign_data);
            if($now - $uid_sign_data[1] == 0){
                return false;
            }elseif ($uid_sign_data[0] == 7 ){
                $num = 1;
                S(self::SignCacheKey($uid),$num.'|'.$now,$expire);
            }else{
                $num = $uid_sign_data[0];
                $num += 1;
                S(self::SignCacheKey($uid),$num.'|'.$now,$expire);
            }
        }

        return $num;

    }

    public function SignCacheKey($uid){
         return 'sign_in_'.$uid;
    }

    /**查询task_type
     * @return mixed
     */
    public function getTaskType($type){
         $where['task_type'] = $type;
         $res = self::where($where)->find();
         if(!$res){
             return false;
         }

         return true;
    }

    /*
     *  获取数据
     */
    public function getData(){
        $list = S(self::TaskCacheKey());
        $where['status'] = self::STATUS_ON;
        if(!$list){
            $list = self::where($where)
                ->field('id,name,describe,task_type,type,num')
                ->select();

            if($list){
                S(self::TaskCacheKey(),serialize($list));
            }
        }else{
            $list = unserialize($list);
        }
        return $list;
    }
    public function clearTaskCache(){
        S(self::TaskCacheKey(),null);
    }

    public function TaskCacheKey(){
        return 'task_list';
    }


}