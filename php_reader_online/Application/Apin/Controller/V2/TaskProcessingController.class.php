<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Admin\Model\TaskModel;
use Apin\Controller\V1\BaseController;
use Common\Controller\Datasource;
use Common\Reflect\TaskController;

class TaskProcessingController extends  BaseController
{
    public function create(){
        $task_model= D('Admin/Task');
        $task_type = $this->parm['task_type'];


        $where['task_type'] = $task_type;
        $where['status'] = TaskModel::STATUS_ON;

        if($task_type == TaskModel::TASK_TYPE_BIND){
            $this->returnResult(400115);
        }

        $is_reader = '';
        $reader_time = '0';

        //处理不正常的参数
        if($task_type == TaskModel::TASK_INVITATION_T){

               $this->returnResult(400100);
        }

        $is_token = 0;
        //如果token存在证明有登陆账户
        if (!empty($this->parm['token'])) {
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }else {
                $is_token = 1;
            }
        }

        //阅读时长处理
        if(in_array($task_type,[TaskModel::TASK_TYPE_READER,TaskModel::TASK_TYPE_READER_30,TaskModel::TASK_TYPE_READER_60])){

                  self::isPositiveInteger($this->parm['reader_time']);
                  $task_type = TaskModel::TASK_TYPE_READER;
                  $is_reader = 1;
                  $reader_time = $this->parm['reader_time'];

                if((new TaskModel())-> checkReaderLimit($this->userinfo['id'], TaskModel::READER_30)){
                    if($is_token){
                        $redis = Datasource::getRedis('instance1');
                        $incr_time = 24*60*60;
                        $redis->hincrby($this->userinfo['uni_id'],$this->parm['token'],$incr_time);
                        $r_time = $redis->ttl($this->parm['token']);
                        $redis->expire(($r_time + $incr_time)-1);
                    }

                }

        }

            $function = $task_model->task_function[$task_type];



        //查看任务是否开放
        $task_data = $task_model->where($where)->find();

        if(!$task_data){
            $this->returnResult(400104);
        }



        //邀请任务
        if($task_type == TaskModel::TASK_INVITATION){
           if(empty($this->parm['invi_code'])){
               $this->returnResult(400100);
           }

//            $this->userinfo = self::check_token($this->parm['token']);
//            if (!$this->userinfo) {
//                $this->returnResult(300108);
//            }

            if(!$this->userinfo['invitation_code']){
                $this->returnResult(300114);
            }

            if($this->parm['invi_code'] == $this->userinfo['invitation_code']){

                $this->returnResult(400116);
            }
            $task_data=  array_merge($task_data,['invi_code' => $this->parm['invi_code'] ,'mobile' => $this->userinfo['mobile']]);

        }

       $reflection =  new \ReflectionClass(TaskController::class);
       $instantiation= $reflection->newInstance();
       $task_data = empty($is_reader)?$task_data:$reader_time;


       $res = $instantiation->$function($task_data,[$this->userinfo['uni_id'],$this->userinfo['id']],$this->header['channel']);

        if(!$res){
            $this->returnResult(2001);
        }


        if(is_numeric($res)){
           $this->returnResult($res);
       }

       $this->returnResult(200,'',$res);
    }

    protected function _check_para($data)
    {
        self::CheckTaskPar($data['task_type']);
    }

    private function CheckTaskPar($task_type){
       $task_model = D('Admin/Task');
       $task_keys = array_keys(($task_model->task_type));
       if(!in_array($task_type,$task_keys)){
           $this->returnResult(400100);
       }

    }
}