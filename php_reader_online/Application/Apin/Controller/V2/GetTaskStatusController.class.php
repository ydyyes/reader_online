<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Apin\Controller\V1\BaseController;


class GetTaskStatusController extends BaseController
{
    public function read(){

        $task_model = D('Admin/Task');

        $task_log = D('Admin/TaskLog');

        //验证是否有token
        if(!empty($this->parm['token']) || $this->parm['id'] == -1 ){

            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        $now_user_sign = $task_model -> getNowSignStatus($this->userinfo['id']);

        $num = S($task_model->SignCacheKey($this->userinfo['id']));
        if(strpos($num,'|')){
            list($num,$time) = explode('|',$num);
        }

        $data['NOW_USER_SIGN'] = $now_user_sign;
        $data['SIGN_CURRNT_NUM'] = $num?:'0';

        $data['SIGN_TOTAL_NUM'] = '7';

        $data['SHARE_TIMES_LIMIT_NUM'] = S($task_log->taskLogCacheLimit($this->userinfo['id']))?:'0';

        $data['SHARE_TIMES_LIMIT'] = D('SysConfig')->getValue('SHARE_TIMES_LIMIT') ?:'3';

        $data['AD_BROWSE_LIMIT_NUM'] = S($task_model->ADBrowseLimitCacheKey($this->userinfo['id']))?:'0';

        $data['AD_BROWSE_LIMIT'] = D('SysConfig')->getValue('AD_BROWSE_LIMIT') ?:'5';

        $data['AD_BROWSE_LIMIT_NUM'] = S($task_model->ADBrowseLimitCacheKey($this->userinfo['id']))?:'0';




        $this->returnResult(200,'',$data);

    }

}