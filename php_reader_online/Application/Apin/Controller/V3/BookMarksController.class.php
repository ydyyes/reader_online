<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V3;


use Apin\Controller\V1\BaseController;
use Admin\Model\BookMarksModel;
use Common\Controller\Datasource;
use Common\Validate\BookMarksValidate;
use Common\Validate\IdMustValidate;

class BookMarksController extends BaseController
{
    public function read(){
        $id   = $this->parm['id'];
        self::isPositiveInteger($id);

        //如果token存在证明有登陆账户
        if (!empty($this->parm['token'])) {
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        $key = (new BookMarksModel)->bookMarkCacheKey($this->userinfo['uni_id'],$id);

        $redis = Datasource::getRedis('instance1');

        $list = $redis -> sMembers($key);
        $time_stemp = $redis -> hGetAll($key.'_timestamp');

        $data_list = [];
        foreach ($list as $val){
            $ex_data = explode('_',$val);
            $data['label'] = $ex_data[0]?:'0';
            $data['percentage'] = $ex_data[1]?:'0';
            $ex_timestemp = explode('_',$time_stemp[$val]);
            $data['timestemp'] = $ex_timestemp[0];
            $data['title'] = $ex_timestemp[1]?:'';
            array_push($data_list,$data);

        }


        $this->returnResult(200,'',$data_list);


    }

    public function save(){

        $id   = $this->parm['id'];
        self::isPositiveInteger($id);

        //如果token存在证明有登陆账户
        if (!empty($this->parm['token'])) {
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        $key = (new BookMarksModel)->bookMarkCacheKey($this->userinfo['uni_id'],$id);

        $is_del     = $this->parm['is_del'];
        $redis = Datasource::getRedis('instance1');

        if($is_del){
            $del_data = json_decode(htmlspecialchars_decode($this->parm['del_data']),true);

            if(!$del_data){
                $this->returnResult(2001);
            }
            $del_arr = [];
            foreach ($del_data as $val){
                $del_arr[] = $val['label'].'_'.$val['percentage'];
            }
            $redis->pipeline();

            foreach ($del_arr as $val){

                $res = $redis->sRem($key,$val);
                if($res){
                    $redis->hdel($key.'_timestamp',$val);
                }

            }
            $redis->exec();


        }else{
            $label      = $this->parm['label'];
            $title      = $this->parm['title'];
            $percentage = sprintf('%.2f',$this->parm['percentage']);
            (new BookMarksValidate())->gocheck(['label' => $label,'percentage' => $percentage]);

            $count_num = $redis->scard($key);

            if($count_num > BookMarksModel::COUNT_NUM){

                $this->returnResult(400118);
            }

            $timestamp = time();
            $redis->sadd($key,$label.'_'.$percentage );
            $redis->hset($key.'_timestamp',$label.'_'.$percentage,$timestamp.'_'.$title);

        }


        $this->returnResult(200,'',[]);



    }





}