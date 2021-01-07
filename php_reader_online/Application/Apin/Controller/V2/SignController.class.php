<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Apin\Controller\V1\BaseController;

class SignController extends BaseController
{
    public function read(){
        $sys_config = D('Admin/SysConfig');
        $res = $sys_config
            ->field('value,comment')
            ->where(['name'=>['like','SIGN_%']])
            ->select();
        return $this->returnResult(200,'',$res);

    }

}