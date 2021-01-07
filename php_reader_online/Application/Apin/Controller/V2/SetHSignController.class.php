<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Common\Controller\Datasource;
use Common\Controller\HSign;
use Think\Controller;

class SetHSignController  extends Controller
{

    public function read(){
        $session_id = 'sess_limit_'.session_id();
        $redis = Datasource::getRedis('instance1');

        if($redis->set($session_id.'_lock', 1, ['nx', 'ex' => 1])) {

            $h_sign = new HSign();
            $encode = $h_sign->setTime();
            session('_HSign', $encode);


        }else{
            die(json_encode(['errorno'=>2001,'msg'=>'操作失败'],JSON_UNESCAPED_UNICODE));
        }

        die(json_encode(['errorno'=>200,'msg'=>'操作成功'],JSON_UNESCAPED_UNICODE));

    }

}