<?php
/**
 * author:liu.
 */

namespace Common\Validate;


class BaseValidate
{

    protected $rule = [];
    private $params=[];
    protected $errorno='';
    protected $errormsg='';
    public function gocheck($data){

        $this->params=$data;

        $res = $this->check();


       if( !$res ){
           header("content:application/json;chartset=uft-8");

           $errorno = $this->errorno?:400100;
           $errorno = (int)$errorno;
           $errormsg = $this->errormsg?:error_msg($errorno);


           die(json_encode(['errorno'=>$errorno,'msg'=>$errormsg],JSON_UNESCAPED_UNICODE));
       }


    }


    public function go_out_error($errorno='400100',$errormsg=null){
        header("content:application/json;chartset=uft-8");
        $errorno = $errorno?:'400100';
        $errorno = (int)$errorno;
        $errormsg =$errormsg?:error_msg($errorno);

        die(json_encode(['errorno'=>$errorno,'msg'=>$errormsg],JSON_UNESCAPED_UNICODE));

    }



    /*
    * 检测方法
    * */

    protected function  isNumber($value){

        if(!is_numeric($value)){
            $this->set_error('400100','参数错误');
            return false;
        }
        return true;
    }

    protected function checkChannelPid($value){
        $res = true;
        if($value !='-1'){
            $res =false;
            if (is_numeric($value) && is_int($value + 0) && ($value + 0) > 0) {
                $res = true;
            }
        }

        return $res;
    }

    protected function isPositiveInteger($value,  $field='')
    {
        if (is_numeric($value) && is_int($value + 0) && ($value + 0) > 0) {
            return true;
        }
        $this->set_error('400103',$field.'参数必须为正整数');
        return false;
    }

    protected function isNotEmpty($value,$field='')
    {

        if (empty($value)) {
            $this->set_error('400100',$field.'参数错误');
            return false;
        } else {
            return true;
        }
    }


    //手机号的验证规则
    protected function isMobile($value)
    {

        $rule = '^1(3|4|5|7|8)[0-9]\d{8}$^';
        $result = preg_match($rule, $value);
        if ($result) {
            return true;
        } else {
            $this->set_error('400102');
            return false;
        }
    }


    /*
     *
     *
     * 验证方法
     */


    private function check(){

        $res = true;

        //获取验证规则
        if( !empty($this->rule) ){

            foreach($this->rule as $k=>$v){
               $res =  $this->eachValidate($k,$v);
               if(!$res){
                   return $res;
               }

            }

        }


        return $res;


    }

    protected function eachValidate( $key,$value ){

        $res = true;
        if(strpos($value,'|')){
            $exp_value = explode('|',$value);

            foreach ($exp_value as $v){

                $res = $this->$v($this->params[$key]);
                if(!$res){
                    return false;
                }

            }

        }else{


            $res = $this->$value($this->params[$key],$key);
                return  $res;
        }

        return $res;


    }


    protected function set_error($errorno=null, $errormsg=null ){

        $this->errorno = $errorno??'';
        $this->errormsg = $errormsg??'';

    }


}