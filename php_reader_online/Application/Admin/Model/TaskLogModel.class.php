<?php
/**
 * author:liu.
 */

namespace Admin\Model;


use Common\Controller\Datasource;

class TaskLogModel extends SystemModel
{
    protected $trueTableName = 'xs_task_log';


    public function setQueue($queue_data){
        $redis = Datasource::getRedis('instance1');
        $redis->rpush(self::queueCacheKey(),$queue_data);
    }
    public function queueCacheKey(){
        return C('REDIS_PREFIX').'task_log_push';
    }
    public function setLimit($uuid){
       $res = S(self::taskLogCacheLimit($uuid));
       if(!$res){
           $res = 0;
       }
       $res++;
       S(self::taskLogCacheLimit($uuid),$res,strtotime('tomorrow')-time());
    }
    public function setInterval($uuid){
        $interval = D('SysConfig')->getValue('SHARE_TIME_INTERVAL')?:900;
        $interval = (int)$interval;
        S(self::taskCacheInterval($uuid),1,$interval);
    }
    public function checkLimit($uuid){
        $limit = D('SysConfig')->getValue('SHARE_TIMES_LIMIT') ?:3;

        if(S(self::taskLogCacheLimit($uuid)) >= $limit){
            return true;
        }
        return false;
    }
    public function checkInterval($uuid){
        if(S(self::taskCacheInterval($uuid))){
            return true;
        }
        return false;
    }

    public function taskCacheInterval($uuid){
        return 'task_interval_'.$uuid;
    }

    public function taskLogCacheLimit($uuid){
        return 'task_log_limit_'.$uuid;
    }
}