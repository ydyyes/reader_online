<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Apin\Controller\V1\BaseController;

class GoldLogController extends  BaseController
{
    public function read(){
        $begin_date_timestamp = date('Y-m-01');
        $end_date_timestamp = strtotime("$begin_date_timestamp +1 month")-1;
        $begin_date_timestamp = strtotime($begin_date_timestamp);

        $page =(int)$this->parm['page']?:1;
        $size =(int)$this->parm['size']?:6;


        //验证是否有token
        if(!empty($this->parm['token']) || $this->parm['id'] == -1 ){
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }
        $where['uid'] = $this->userinfo['id'];
        $where['create_time'] = ['BETWEEN',[$begin_date_timestamp,$end_date_timestamp]];
        $gold_model = D('Admin/GoldLog');
        $start = ($page-1)*$size;
        $data = $gold_model->where($where)
            ->limit($start,$size)
            ->order('create_time desc')
            ->select();

        $data = array_map(function($v){
            unset($v['uid']);
            $v['create_time'] = date('Y年m月d日 H:i',$v['create_time']);
            return $v;
        },$data);


        $this->returnResult(200,'',$data);


    }

}