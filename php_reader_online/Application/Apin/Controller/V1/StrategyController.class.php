<?php
/**
 *
 * User: liu
 */

namespace Apin\Controller\V1;


class StrategyController extends BaseController
{
    protected $no_uuid = 1;
    public function read(){
        $data = ['STRATEGY_FREE_AD_OPEN','STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY','STRATEGY_FREE_AD_SHOW_INTV'
                ,'STRATEGY_AD_OPEN','STRATEGY_AD_CHAPTER_END_INTV','STRATEGY_AD_OPEN','STRATEGY_AD_CHAPTER_END_INTV'
                ,'AD_BROWSE_LIMIT','EXCHANGE_GOLD_NUM','SHARE_TIMES_LIMIT','STRATEGY_START_RATIO','STRATEGY_CHAPTER_END_RATIO',
                'STRATEGY_VIDEO_RATIO','STRATEGY_RED_PACKET','BANNER_AD_SWITCH','BANNER_AD_RATIO','BANNER_AD_LIMIT'
        ];
        $res_arr = [];
        $diff_arr=[];
        $sys_config = D('Admin/SysConfig');
        $config_arr = $sys_config->where(['status' => 1])
            ->field('id,name,value')
            ->select();
        foreach ($config_arr as $k => $v){
            if(in_array($v['name'],$data)){
                array_push($diff_arr,$v['name']);
                $res_arr[$v['name']] = $v['value'];
            }
        }

        //后台没有设置的信息处理
       $diff = array_diff($data,$diff_arr);
        foreach ($diff as $name){
            $res_arr[$name] = '0';
        }
        $this->returnResult(200,'',$res_arr);

    }

}