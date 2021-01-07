<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


class TaskController  extends BaseController
{
    protected $no_uuid = 1;
    public function read(){
        $task_model = D('Admin/Task');
        $data = $task_model->getData();
        $this->returnResult(200,'',$data);
    }

}