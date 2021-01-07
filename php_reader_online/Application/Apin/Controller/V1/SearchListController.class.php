<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\NovelsModel;
use Common\Controller\Datasource;

class SearchListController extends BaseController
{
    protected $no_uuid = 1;
    public function read(){
        $novel_model = D('Admin/Novels');
        $page =(int)$this->parm['page']?:1;
        $size =(int)$this->parm['size']?:6;
        $key = htmlspecialchars($this->parm['key']);
        $data = $novel_model->SearchList($key,$page,$size);
        if($data){
            $redis = Datasource::getRedis('instance1');
            $redis->zincrby($novel_model->hotCacheKey(),1,$key);
            $count = $redis->zcard($novel_model->hotCacheKey());
            if($count > NovelsModel::LIMIT_HOT_KET){
                $num = $count-1000;
                $redis->ZREMRANGEBYRANK($novel_model->hotCacheKey(),0,$num);
            }
        }
        return $this->returnResult(200,'',$data);
    }
    protected function _check_para($data){
        if(empty($data['key'])){
            $this->returnResult(400101);
        }
    }

}