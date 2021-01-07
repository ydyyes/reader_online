<?php

namespace Admin\Controller\User;

use Admin\Controller\SystemController;

/**
 * Class UserListController
 * @package Admin\Controller
 */
class UserPaidLogController extends SystemController
{
    public $model = "user_paid_log";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['pay_or']))
        {
            $map['pay_or'] = $_search['pay_or'];
        }
        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
    }

    public function _before()
    {
        $this->assign('status', ['0'=>'失败','1'=>'成功']);
        $this->assign('type', D($this->model)->type);
    }
}