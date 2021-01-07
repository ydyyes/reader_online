<?php
/**
 * User:Xxx
 */

namespace Cli\Controller;


class EditOrderStatusController extends ClibaseController
{
    public function start(){
        D('Admin/Order') -> expire_order();
    }

}