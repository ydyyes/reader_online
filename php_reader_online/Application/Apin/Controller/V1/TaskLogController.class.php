<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\TaskModel;
use Common\Controller\Datasource;
use Common\Validate\IdMustValidate;

class TaskLogController extends BaseController
{
    public function create(){
        //限制
        $task_model= D('Admin/Task');
        $task_type = 2;
        $function = $task_model->task_function[$task_type];
        $where['task_type'] = 2;
        $where['status'] = TaskModel::STATUS_ON;
        //查看任务是否开放
        $task_data = $task_model->where($where)->find();

        if(!$task_data){
            $this->returnResult(400104);
        }

        //如果token存在证明有登陆账户
        if(!empty($this->parm['token'])){
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        $reflection =  new \ReflectionClass(\Common\Reflect\TaskController::class);
        $instantiation= $reflection->newInstance();
        $res = $instantiation->$function($task_data,[$this->userinfo['uni_id'],$this->userinfo['id']],$this->header['channel']);

        if(!$res){
            $this->returnResult(2001);
        }


        if(is_numeric($res)){
            $this->returnResult($res);
        }

        $this->returnResult(200,'',$res);

    }

//    protected function _check_para($data){
//        (new IdMustValidate())->gocheck($data);
//    }


}