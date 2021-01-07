<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Common\Controller\Datasource;

class UserInfoController extends BaseController
{
    protected $no_uuid = 1;
    public function read(){

        $usersModel = D('Admin/Users');
        if (!empty($this->parm['token']))
        {
            $redis = Datasource::getRedis('instance1');
            $info = $redis->hgetall($this->parm['token']);
            if(!$info){
                    $this->returnResult(300108);
            }
            $res = $usersModel->getVipData($info['expire']);
            if($res){
                $data['expire'] = $info['expire'];
            }else{
                $data['expire'] = '0';
            }

            $data['id']     = $info['id'];
            $data['uni_id'] = $info['uni_id'];
            $data['gold']   = $info['gold'];
            $data['devid']  = $info['devid'];
            $data['utid']   = $info['utid'];

            $data['sex']   = $info['sex'];

            if($info['cover'])
                $data['cover'] = strrpos($info['cover'], 'http') ? $info['cover'] : cdn('ATTACH') . $info['cover'];
            else
                $data['cover'] = '';

            //查看该用户是否已经填写过邀请码了
            $invitation_model = D('Admin/Invitation');
            $invitation_pa_res = $invitation_model->checkPaInviation($info['id']);
            $data['invitation'] = $invitation_pa_res?'1':'0';

            //阅读时长
            $task_model = D('Admin/Task');
            $data['reader_time'] = $task_model -> getTaskReaderTimeCache($data['id']);

            $data['u_type'] = $usersModel->userTypes[$info['utid']];
            $data['invitation_code'] = $info['invitation_code']?:'';
            $data['username'] = $info['username'];
            $data['mobile'] = $info['mobile'];
            $data['expire'] = $info['expire'];
            $data['nickname'] = $info['nickname'];
            $data['expire'] = $info['expire'];

        } else {
            $data = self::UUIDLogin();
            if($data['cover'])
                $data['cover'] = strrpos($data['cover'], 'http') ? $data['cover'] : cdn('ATTACH') . $data['cover'];
            else
                $data['cover'] = '';

            //查看该用户是否已经填写过邀请码了
            $invitation_model = D('Admin/Invitation');
            $invitation_pa_res = $invitation_model->checkPaInviation($data['id']);
            $data['invitation'] = $invitation_pa_res?'1':'0';

            //阅读时长
            $task_model = D('Admin/Task');
            $data['reader_time'] = $task_model -> getTaskReaderTimeCache($data['id']);

            unset($data['login_type']);

        }

        return $this->returnResult(200,'',$data);

    }

}