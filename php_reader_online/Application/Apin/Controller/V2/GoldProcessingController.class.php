<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;

use Apin\Controller\V1\BaseController;
use Common\Reflect\GoldController;
use Common\Validate\IdMustValidate;

class GoldProcessingController extends BaseController
{
    public function save(){
        $function = 'goldBook';

        //兑换列表数据
        if($this->parm['id'] != -1 ){
            $function = 'goldTime';
            $gold_model = D('Admin/ExchangeGold');
            $data = $gold_model->getStatus($this->parm['id']);
            if(!$data){
                $this->returnResult(400104);
            }

        }else{
            //书籍下载所需数据
            $data['id'] = $this->parm['id'];
            $data['b_id'] = $this->parm['b_id'];
            $data['cost_gold'] =D('SysConfig')->getValue('EXCHANGE_GOLD_NUM') ? : 100;
        }

        //验证是否有token,或者是下载权限
        if(!empty($this->parm['token']) ){
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        //兑换会员时间及书籍
        $reflection =  new \ReflectionClass(GoldController::class);
        $instantiation= $reflection->newInstance();
        $res = $instantiation->$function($data,$this->userinfo);


        if(!$res){
            $this->returnResult(2001);
        }


        if(is_numeric($res)){
            $this->returnResult($res);
        }
        if($res == 'success')
           $this->returnResult(200,'');
        else
            $this->returnResult(2001,'');

    }

    protected function _check_para($data)
    {
        if($data['id'] != -1 )
            (new IdMustValidate())->gocheck($data);
        else
            self::isPositiveInteger($data['b_id']);
    }

}