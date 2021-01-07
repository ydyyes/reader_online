<?php
/**
 * User:Xxx
 */

namespace Common\Reflect;


use Admin\Model\TaskModel;
use Common\Controller\Datasource;
use Think\Controller;
use Think\Exception;

class BaseController extends Controller
{

    public function goldDisposeBook($data,$userinfo){


        try {
            $user_model = D('Admin/Users');
            $redis = Datasource::getRedis('instance1');

            $where['id'] = $userinfo['id'];
            $res = $user_model->where($where)->setDec('gold',$data['cost_gold']);

            if ($res) {
                $list = $redis->hgetall($userinfo['uni_id']);
                foreach ($list as $k => $v) {
                    if ($redis->hget($k, 'uni_id')) {
                        $redis->hincrby($k, 'gold', '-' . $data['cost_gold']);
                    }
                }

                $glod_log_model = D('Admin/GoldLog');
                $gold_add['uid'] = $userinfo['id'];
                $gold_add['name'] = $data['name'];
                $gold_add['eid'] = $data['id'];
                $gold_add['etype'] = 0;
                $gold_add['describe'] = $data['describe'];
                $gold_add['num'] = '-' . $data['cost_gold'];
                $gold_add['create_time'] = time();
                $glod_log_model->add($gold_add);
            }


        }catch (\Exception $e){
            $data = json_encode([$data,$userinfo]);
            \Think\Log::write($data.' DIR:'.__METHOD__.' ERROR:'.$e->getMessage(),'SELF_ERROR');
            return false;

        }
        return $res;

    }
       public function goldDispose($data,$userinfo){

           try {
               $user_model  = D('Admin/Users');
               $redis = Datasource::getRedis('instance1');
               $where['id'] = $userinfo['id'];
               $save['gold'] = array('exp', 'gold-' . $data['cost_gold']);
               $expire = $user_model->getVipData($userinfo['expire']);
               $num = $data['num'] * 3600;
               if ($expire) {
                   $save['expire'] = $userinfo['expire'] + $num;
               } else {
                   $save['expire'] = time() + $num;
               }
               $res = $user_model->where($where)->save($save);
               if ($res) {
                   $list = $redis->hgetall($userinfo['uni_id']);
                   foreach ($list as $k => $v) {
                       if ($redis->hget($k, 'uni_id')) {
                           $redis->hset($k,'expire',$save['expire']);
                           $redis->hincrby($k, 'gold', '-' . $data['cost_gold']);
                       }
                   }


                   $glod_log_model = D('Admin/GoldLog');
                   $gold_add['uid'] = $userinfo['id'];
                   $gold_add['eid'] = $data['id'];
                   $gold_add['etype'] = $data['type'];
                   $gold_add['name'] = $data['name'];
                   $gold_add['describe'] = $data['describe'];
                   $gold_add['num'] = '-' . $data['cost_gold'];
                   $gold_add['create_time'] = time();
                   $glod_log_model->add($gold_add);
               }
           }catch (\Exception $e){
               $data = json_encode([$data,$userinfo]);
               \Think\Log::write($data.' DIR:'.__METHOD__.' ERROR:'.$e->getMessage(),'SELF_ERROR');
               return false;

           }

        return $res;


       }
        //任务处理
        public function addDate($task_data,$user_info,$channel)
        {
            try {
                $user_model = D('Admin/Users');
                $redis = Datasource::getRedis('instance1');
                if ($task_data['type'] == TaskModel::TASK_DAY) {


                    $expire = $user_model->where(['uni_id' => $user_info[0]])->getField('expire');
                    $is_expire = $user_model->getVipData($expire);
                    $num = $task_data['num'] * 3600;
                    if ($is_expire) {
                        $expire = $expire + $num;
                    } else {
                        $expire = time() + $num;
                    }
                    $res = $user_model->where(['uni_id' => $user_info[0]])->save(['expire' => $expire]);
                    if ($res) {
                        $list = $redis->hgetall($user_info[0]);
                        foreach ($list as $k => $v) {
                            if ($redis->hget($k, 'uni_id')) {
                                $redis->hset($k, 'expire', $expire);
                            }
                        }
                        $task_log_model = D('Admin/TaskLog');
                        $task_add['uid'] = $user_info[1];
                        $task_add['tid'] = $task_data['id'];
                        $task_add['type'] = TaskModel::TASK_DAY;
                        $task_add['num'] = $task_data['num'];
                        $task_add['channel'] = $channel;
                        $task_add['create_time'] = time();
                        $task_add['update_time'] = time();
                        //记录进任务日志表
                        $task_log_model->add($task_add);
                    }

                } else {

                    $res = $user_model->where(['uni_id'=>$user_info[0]])->setInc('gold',$task_data['num']);

                    if($res){
                        $list = $redis->hgetall($user_info[0]);
                        foreach ($list as $k => $v){
                            if($redis->hget($k,'uni_id')){
                                $redis->hincrby($k,'gold',$task_data['num']);
                            }
                        }

                        $task_log_model = D('Admin/TaskLog');
                        $glod_log_model = D('Admin/GoldLog');
                        $task_add['uid'] = $user_info[1];
                        $task_add['tid'] = $task_data['id'];
                        $task_add['type'] = TaskModel::TASK_GOLD;
                        $task_add['num'] = $task_data['num'];
                        $task_add['channel'] = $channel;
                        $task_add['create_time'] = time();
                        $task_add['update_time'] = time();
                        $gold_add['uid'] = $user_info[1];
                        $gold_add['name'] = $task_data['name'];
                        $gold_add['num'] = $task_data['num'];
                        $gold_add['create_time'] = time();
                        $describe= D('Admin/Task')->task_type_gold[$task_data['task_type']];
                        if($task_data['task_type'] == TaskModel::TASK_TYPE_SIGN){
                            $gold_add['describe'] = sprintf($describe,$task_data['day'],$task_data['num'].'金币');
                        }else{
                            $gold_add['describe'] = sprintf($describe,$task_data['num'].'金币');
                        }


                        //记录进任务日志表
                        $task_log_model->add($task_add);
                        $glod_log_model->add($gold_add);


                    }






                }
        }catch (\Exception $e){
                $data = json_encode([$task_data,$user_info,$channel]);
                \Think\Log::write($data.' DIR:'.__METHOD__.' ERROR:'.$e->getMessage(),'SELF_ERROR');
                return false;
            }

            return $res;

        }


}