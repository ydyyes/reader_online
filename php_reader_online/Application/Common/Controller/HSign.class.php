<?php
/**
 * User:Xxx
 */

namespace Common\Controller;


class HSign
{
    protected $chiArr = [];
    private   $slipStr = '209832';

    protected function chineseRepo(){
        $res_arr = [];
        $arr_repo = $this->chiArr;
        $function = ['sha1','md5','crypt','base64_encode'];
        $arr_keys = array_rand($arr_repo,6);

        foreach ($arr_keys as $k=>$v){
            $func = $function[$v%3];
            $res = $func($arr_repo[$v]);
            array_push($res_arr,$res);
        }

        return $res_arr;
    }

    public function setTime(){

          return time();
    }

    public function getHLimit(){
        $session_id = session_id();
        $redis = Datasource::getRedis('instance1');
        $limit_num = $redis->incr($session_id . '_req_limit');

        if ($limit_num == 1) {
            $redis->expire($session_id . '_req_limit', 60);
        } elseif ($limit_num > 50) {
            return false;
        }

        return true;

    }




    public function Encode(){
        $res_arr = [];
        $res_arr =  self::chineseRepo();
        $time = self::PrepareSet();
        $res_arr[1] = substr_replace(substr($res_arr[1],1),$time[0][0],'2','1');
        $res_arr[1] = substr_replace(substr($res_arr[1],1),$time[0][1],'4','1');
        $res_arr[3] = substr_replace(substr($res_arr[3],1),$time[1][0].$time[1][1],'3','2');
        $res_arr[4] = substr_replace(substr($res_arr[4],1),$time[2][0].$time[2][1],'4','2');
        $res_arr[5] = substr_replace(substr($res_arr[5],1),$time[3][0].$time[3][1].$time[3][2],'5','3');
        $res_arr[5] =  substr_replace(substr($res_arr[5],1),$time[3][3],20,'1');
        $res_end = implode($this->slipStr,$res_arr);

        return $res_end;
    }

    public function DnCode($sign = null){
        if(!$sign){
            return false;
        }
        $ex_arr = explode($this->slipStr,$sign);
        $encode = '';
        if($ex_arr['1'] && $ex_arr['3'] && $ex_arr['4'] && $ex_arr['5']) {
            $encode = substr($ex_arr['1'], 1, 1);
            $encode .= substr($ex_arr['1'], 4, 1);
            $encode .= substr($ex_arr['3'], 3, 2);
            $encode .= substr($ex_arr['4'], 4, 2);
            $encode .= substr($ex_arr['5'], 4, 3);
            $encode .= substr($ex_arr['5'], 20, 1);
        }

        return $encode;
    }

    protected function PrepareSet(){
        $time =time();
        $time_arr=[];
        for ($i=0;$i<4;$i++) {
            $num =2*$i;
            if($i != 3){
                array_push($time_arr, substr($time, $num, 2));
            }else{
                array_push($time_arr, substr($time, $num));
            }
        }
        return $time_arr;

    }

    public function setChiArr(){
        $arr_repo = ['去','我','饿','反','天','用','发','哦','片',
            '啊','是','的','个','冰','写','你','嘛','问'
        ];

        $this->chiArr = $arr_repo;
    }

}