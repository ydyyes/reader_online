<?php
/**
 * User:Xxx
 */

namespace Vend\Controller;


use Common\Controller\Datasource;
use Think\Controller;

class YouMiCallbackController extends Controller
{

    public function add(){
        $get_data = $_GET;

        try {
            if (!empty($get_data['device'])) {

                if (is_numeric($get_data['device'])) {
                    //android
                    $res_sign = self::android_sign($get_data);
                    if (empty($get_data['sig']) || ($res_sign != $get_data['sig'])) {

                        header(http_code(503));
                        throw new \Exception(' android error sign ');
                    }

                } else {
                    //IOS
                    $res_sign = self::ios_sign($get_data);

                    if (empty($get_data['sign']) || ($res_sign != $get_data['sign'])) {

                        header(http_code(503));
                        throw new \Exception('ios error sign ');
                    }


                }

                      $order_log = D()->table('xs_youmi_log')->where(['order_id' => $get_data['order']])->find();

                        if(!$order_log){
                            $get_data['points'] = (int)$get_data['points'];
                            $data['order_id']  = $get_data['order'];
                            $data['y_time']    = $get_data['time'];
                            $data['uni_id']    = $get_data['user'];
                            $data['gold']      = (int)$get_data['points'];
                            $data['json_data'] = json_encode($get_data);
                            $data['create_time'] = time();
                            D()->startTrans();
                            $redis = Datasource::getRedis('instance1');
                            $user_model = D('Admin/Users');
                            $res1 = $user_model->where(['uni_id' => $get_data['user']])->setInc('gold',$get_data['points']);
                            $res2 = D()->table('xs_youmi_log')->add($data);

                            if($res1 && $res2){
                                D()->commit();
                                $list = $redis->hgetall($get_data['user'] );
                                foreach ($list as $k => $v){
                                    if($redis->hget($k,'uni_id')){
                                        $redis->hincrby($k,'gold',$get_data['points']);
                                    }
                                }

                                $user_info = $user_model -> getUserInfoByUniId($get_data['user']);

                                $gold_add['uid']  = $user_info['id']?:0;
                                $gold_add['name'] = '下载应用领金币';
                                $gold_add['num']  = $get_data['points'];
                                $gold_add['describe'] = sprintf('下载任务领金币对应任务完成奖励%s',$get_data['points'].'金币');
                                $gold_add['create_time'] = time();

                                D('Admin/GoldLog') -> add($gold_add);



                        }else{
                                header(http_code(503));
                                D()->rollback();
                                throw new \Exception('order Failed to create');


                            }


                        }else{
                            header(http_code('403'));
                            exit;

                        }


            } else {
                header(http_code(503));
                throw new \Exception('no device');
                exit;
            }
        }catch (\Exception $e){
            header(http_code(503));
            \Think\Log::write('YouMi:'.json_encode($get_data).'  Error:'.$e->getMessage(),'YouMiError');
            exit;

        }

    }

    private function ios_sign($get_data){
        unset($get_data['sign']);
        $str = '';
        $secret = C('dev_server_secret');
        ksort($get_data);

        foreach ($get_data as $k => $v) {
            $str .= "{$k}={$v}";
        }
        $str .= $secret;
        return md5($str);

    }

    private function android_sign($get_data){
        $sig = substr(md5(C('dev_server_secret') . "||" . $get_data['order'] . "||" . $get_data['app'] . "||" . $get_data['user'] . "||" . $get_data['chn'] . "||" . $get_data['ad'] . "||" . $get_data['points']), 12, 8);
        return $sig;
    }

}