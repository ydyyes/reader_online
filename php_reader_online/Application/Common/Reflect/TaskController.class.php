<?php
/**
 * User:Xxx
 */

namespace Common\Reflect;


use Admin\Model\TaskModel;
use Common\Controller\Datasource;

class TaskController extends BaseController
{

    public function invitationAward($task_data ,$user_info ,$channel){
        $invitation_model = D('Admin/Invitation');

        //查看该用户是否已经填写过邀请码了
        $invitation_pa_res = $invitation_model->checkPaInviation($user_info[1]);

        if($invitation_pa_res){
            return 400117;
        }

        //查找对应邀请码的用户
        $user_model = D('Admin/Users');
        $userinfo_by_inviation = $user_model->findByInviation($task_data['invi_code']);

        if(!$userinfo_by_inviation ){
            return 400116;
        }


        $invitation_log['uid'] = $userinfo_by_inviation['id'];
        $invitation_log['pa_uid'] = $user_info[1];
        $invitation_log['pa_mobile'] = $task_data['mobile'];
        $invitation_log['create_time'] = time();



        $invitation_res = $invitation_model->add($invitation_log);

        if($invitation_res){

                try {
                    /*判断邀请是否达到限制
                           /查看任务是否开放
                     */
                    $task_model= D('Admin/Task');
                    $task_log_model = D('Admin/TaskLog');
                    $glod_log_model = D('Admin/GoldLog');

                    $where['task_type'] = TaskModel::TASK_INVITATION_T;
                    $where['status'] = TaskModel::STATUS_ON;
                    $task_inviation_t = $task_model->where($where)->find();
                    $is_task_inviation_t = '';
                    $gold_add_t_ok = [];
                    if($task_inviation_t){
                        $count = $invitation_model->checkInviationT($userinfo_by_inviation['id']);

                        if($count == TaskModel::TASK_INVIATION_T_NUM){
                            $is_task_inviation_t = 1;
                            $task_inviation_t_ok_num = $task_data['num'] + $task_inviation_t['num'];

                            //被邀请者
                            $gold_add_t_ok['uid'] = $userinfo_by_inviation['id'];
                            $gold_add_t_ok['name'] = $task_inviation_t['name'];
                            $gold_add_t_ok['num'] = $task_inviation_t['num'];
                            $gold_add_t_ok['create_time'] = time();
                            $gold_add_t_ok['describe'] = sprintf(D('Admin/Task')->task_inviation['inviation_t'],$task_inviation_t['num'].'金币');


                        }
                    }


                    $user_model = D('Admin/Users');
                    $redis = Datasource::getRedis('instance1');

                        $res1 = $user_model->where(['uni_id'=>$user_info[0]])->setInc('gold',$task_data['num']);

                        if($is_task_inviation_t != 1){
                            $inviation_c_t_num = $task_data['num'];
                            $res2 = $user_model->where(['uni_id'=>$userinfo_by_inviation['uni_id']])->setInc('gold',$task_data['num']);
                        }else{
                            $inviation_c_t_num = $task_inviation_t_ok_num;
                            $res2 = $user_model->where(['uni_id'=>$userinfo_by_inviation['uni_id']])->setInc('gold',$task_inviation_t_ok_num);
                        }

                        if($res1 && $res2){


                            if(!$task_data){
                                $this->returnResult(400104);
                            }

                            $list = $redis->hgetall($user_info[0]);
                            foreach ($list as $k => $v){
                                if($redis->hget($k,'uni_id')){
                                    $redis->hincrby($k,'gold',$task_data['num']);
                                }
                            }
                            $list2 = $redis->hgetall($userinfo_by_inviation['uni_id']);
                            foreach ($list2 as $k => $v){
                                if($redis->hget($k,'uni_id')){
                                    $redis->hincrby($k ,'gold' ,$inviation_c_t_num);
                                }
                            }



                            $task_add['uid'] = $userinfo_by_inviation['id'];
                            $task_add['tid'] = $task_data['id'];
                            $task_add['type'] = TaskModel::TASK_GOLD;
                            $task_add['num'] = $task_data['num'];
                            $task_add['channel'] = $channel;
                            $task_add['create_time'] = time();
                            $task_add['update_time'] = time();



                            //邀请好友
                            $gold_add['uid'] = $userinfo_by_inviation['id'];
                            $gold_add['name'] = $task_data['name'];
                            $gold_add['num'] = $task_data['num'];
                            $gold_add['create_time'] = time();
                            $gold_add['describe'] = sprintf(D('Admin/Task')->task_inviation['inviation'],$task_data['num'].'金币');

                            //被邀请者
                            $gold_add_pa['uid'] = $user_info[1];
                            $gold_add_pa['name'] = $task_data['name'];
                            $gold_add_pa['num'] = $task_data['num'];
                            $gold_add_pa['create_time'] = time();
                            $gold_add_pa['describe'] = sprintf(D('Admin/Task')->task_inviation['inviation_pa'],$task_data['num'].'金币');

                            $gold_add_all[] = $gold_add;
                            $gold_add_all[] = $gold_add_pa;

                            if($gold_add_t_ok){
                                $gold_add_all[] =  $gold_add_t_ok;
                            }


                            //记录进任务日志表
                            $task_log_model->add($task_add);
                            $glod_log_model->addAll($gold_add_all);



                        }


                }catch (\Exception $e){
                    $data = json_encode([$task_data,$user_info,$channel]);
                    \Think\Log::write($data.' DIR:'.__METHOD__.' ERROR:'.$e->getMessage(),'SELF_ERROR');
                    return false;
                }

                $res = ['res'=>true];
                return $res;
            }




    }

    public function signAward($task_data ,$user_info ,$channel){
        $task_model = D('Admin/Task');
        $num = $task_model->signDate($user_info[1]);
        if(!$num){
            return 400114;
        }
        $task_data['day'] = $num;
        $task_data['num'] =  D('SysConfig')->getValue('SIGN_'.$num) ? :'20';
        $res = self::addDate($task_data,$user_info,$channel);
        if(!$res){
            return false;
        }
        $return= ['num'=>$task_data['day'],'total'=>'7'];
        return $return;

    }
    public function shareAward($task_data ,$user_info ,$channel){

        $task_log = D('Admin/TaskLog');

        if($task_log->checkLimit($user_info[1])){
            return 400113;
        }

        if($task_log->checkInterval($user_info[1])){
            return 400114;
        }

        $res = self::addDate($task_data,$user_info,$channel);

        if(!$res){
            return false;
        }
        $task_log->setLimit($user_info[1]);
        $task_log->setInterval($user_info[1]);

        $total = D('SysConfig')->getValue('SHARE_TIMES_LIMIT') ?:'3';
        $num = S($task_log->taskLogCacheLimit($user_info[1]));
        $return = ['num'=>$num,'total'=>$total];
        return $return;

    }
    public function readerAward($task_data ,$user_info ,$channel){

        //阅读时长设置
        $task_model = D('Admin/Task');
        $task_model  -> SetTaskReaderTimeCache($user_info[1],$task_data);

        if(!is_numeric($task_data) || $task_data < 1800){
            return false;
        }

        $redis = Datasource::getRedis('instance1');
        $res = false;
        $res_data = false;

        if($redis->set(self::lockReaderTime($user_info[1]), 1, ['nx', 'ex' => 180])) {


            if($task_data < 1800){
                return 2001;
            }

            if ($task_data >= 1800 && $task_data < 3600) {

                if($task_model->checkReaderLimit($user_info[1], TaskModel::READER_30)){

                    $res_data = self::readerT($user_info ,$channel,TaskModel::TASK_TYPE_READER_30);
                    $task_model->setReaderLimit($user_info[1],TaskModel::READER_30);
                }


            } elseif ($task_data >= 3600 && $task_data < 7200) {
                if($task_model->checkReaderLimit($user_info[1],TaskModel::READER_30)){
                    $res_data = self::readerT($user_info ,$channel,TaskModel::TASK_TYPE_READER_30);
                    $task_model->setReaderLimit($user_info[1],TaskModel::READER_30);

                    }
                if($task_model->checkReaderLimit($user_info[1],TaskModel::READER_60)){
                    $res_data = self::readerT($user_info ,$channel,TaskModel::TASK_TYPE_READER_60);
                    $task_model->setReaderLimit($user_info[1],TaskModel::READER_60);

                }

            } else {
                if($task_model->checkReaderLimit($user_info[1],TaskModel::READER_30)){

                    $res_data = self::readerT($user_info ,$channel,TaskModel::TASK_TYPE_READER_30);
                    $task_model->setReaderLimit($user_info[1],TaskModel::READER_30);

                }
                if($task_model->checkReaderLimit($user_info[1],TaskModel::READER_60)){

                    $res_data = self::readerT($user_info ,$channel,TaskModel::TASK_TYPE_READER_60);
                    $task_model->setReaderLimit($user_info[1],TaskModel::READER_60);

                }
                if($task_model->checkReaderLimit($user_info[1],TaskModel::READER_120)){
                    $res_data = self::readerT($user_info ,$channel,TaskModel::TASK_TYPE_READER);
                    $task_model->setReaderLimit($user_info[1],TaskModel::READER_120);

                }

            }



            $redis->del(self::lockReaderTime($user_info[1]));

        }else{
            return 2001;
        }

        if($res_data){
                $res = ['res'=>true];
        }

         return $res;

    }
    public function bindAward($task_data ,$user_info ,$channel){

        $res = self::addDate($task_data,$user_info,$channel);
        if(!$res){
            return false;
        }
        return true;

    }
    public function browseAward($task_data ,$user_info ,$channel){
        $task_model = D('Admin/Task');
        if($task_model->CheckADBrowseLimit($user_info[1])){
            return 400113;
        }

        $res = self::addDate($task_data,$user_info,$channel);
        if(!$res){
            return false;
        }

        $task_model->setADBrowseLimit($user_info[1]);
        $total = D('SysConfig')->getValue('AD_BROWSE_LIMIT') ?:'5';
        $num = S($task_model->ADBrowseLimitCacheKey($user_info[1]));
        $return = ['num'=>$num,'total'=>$total];
        return $return;
    }


    private  function readerT($user_info ,$channel ,$task_type){
        $where['task_type'] = $task_type;
        $where['status'] = TaskModel::STATUS_ON;
        $task_model = D('Admin/Task');
        //查看任务是否开放
        $task_data = $task_model->where($where)->find();

        if(!$task_data){
            return false;
        }

        $res = self::addDate($task_data,$user_info,$channel);


        return $res;

    }

    private function lockReaderTime($uid){
        return C('REDIS_PREFIX').'lock_reader_time_'.$uid;
    }


}