<?php
/**
 * author:liu.
 */

namespace Admin\Controller\Task;


use Admin\Controller\SystemController;

class TaskListController  extends SystemController
{
    public $model = 'task';

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['name']))
        {
            $map['name'] = $_search['name'];
        }

        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
    }

    public  function _before_insert(){
        if(empty($_POST['task_type'])){
            $this->error('任务类型不能为空');
        }

        $task_model = D($this->model);
        $task_type_res = $task_model -> getTaskType($_POST['task_type']);

        if($task_type_res) {
            $this->error('任务类型已经存在');
        }
    }

    public function _before(){

       $task_model = D($this->model);
       $type = $task_model->type;
       $way = $task_model->way;
       $status = $task_model->status;
       $task_type = $task_model->task_type;

       $this->assign('task_type',$task_type);
       $this->assign('type',$type);
       $this->assign('way',$way);
       $this->assign('status',$status);
    }

    public function _after_insert(){
        D($this->model)->clearTaskCache();
    }

    public function _after_update(){
        D($this->model)->clearTaskCache();
    }


}