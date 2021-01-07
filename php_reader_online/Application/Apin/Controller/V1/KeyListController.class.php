<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\NovelsModel;
use Common\Controller\Datasource;

class KeyListController  extends BaseController
{
    protected $no_uuid = 1;
    public function read(){
        $novel_model = D('Admin/Novels');
        $redis = Datasource::getRedis('instance1');
        $data = $redis->zrevrange($novel_model->hotCacheKey(),0,NovelsModel::HOT_KET_END);

        return $this->returnResult(200,'',$data);
    }

}