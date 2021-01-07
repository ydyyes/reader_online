<?php
/**
 * author:liu.
 */

namespace Admin\Controller;


use Admin\Model\CatesModel;
use Common\Controller\Datasource;

class ClearCacheController extends SystemController
{
    public function index(){
        $redis = Datasource::getRedis('instance1');
        $novels_list = $redis->keys(C('REDIS_PREFIX').'novels_list_*');
        foreach ($novels_list as $k=>$v){
            $redis->del($v);
        }


        $recomment_list = $redis->keys(C('REDIS_PREFIX').'recommend_list_*');
        foreach ($recomment_list as $k=>$v){
            $redis->del($v);
        }

        $rand_recomment_list = $redis->keys(C('REDIS_PREFIX').'rand_recommend_list_*');
        foreach ($rand_recomment_list as $k=>$v){
            $redis->del($v);
        }

        $h_novels_list = $redis->keys(C('REDIS_PREFIX').'h_novels_list_newcharts_*');
        foreach ($h_novels_list as $k=>$v){
            $redis->del($v);
        }

        //清除小说类型状态缓存
        (new CatesModel()) -> clearCates();

        echo 'done';
}

}