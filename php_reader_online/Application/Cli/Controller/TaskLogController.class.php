<?php
/**
 * author:liu.
 */

namespace Cli\Controller;


use Admin\Model\TaskModel;
use Common\Controller\Datasource;

class TaskLogController extends ClibaseController
{
    public function start(){
        $redis = Datasource::getRedis('instance1');
        $task_model = D('Admin/TaskLog');
        $key =$task_model->queueCacheKey();
        while($data = $redis->lpop($key)){
           $data = explode('|',$data);
           if($data[0] && $data[1]){
               self::data_save($data);

           }
        }
    }

    protected function data_save($data){
        $user_model =D('Admin/Users');
        $redis = Datasource::getRedis('instance1');
        $res = '';
        if($data[1] ==TaskModel::TASK_DAY ){
            $expire = $user_model->where(['uni_id'=>$data[0]])->getField('expire');
            $is_expire = $user_model->getVipData($expire);
            $num = $data[2]*3600;
            if($is_expire){
                $expire = $expire + $num;
            }else{
                $expire = time() + $num;
            }
            $res = $user_model->where(['uni_id'=>$data[0]])->save(['expire'=>$expire]);
            if($res){
                $list = $redis->hgetall($data[0]);
                foreach ($list as $k => $v){
                    if($redis->hget($k,'uni_id')){
                        $redis->hset($k,'expire',$expire);
                    }
                }
            }

        }elseif($data[1] == TaskModel::TASK_GOLD){
            $res = $user_model->where(['uni_id'=>$data[0]])->setInc('gold',$data[2]);
            if($res){
                $list = $redis->hgetall($data[0]);
                foreach ($list as $k => $v){
                    if($redis->hget($k,'uni_id')){
                        $redis->hincrby($k,'gold',$data[2]);
                    }
                }
            }

        }

            return $res;
    }

}