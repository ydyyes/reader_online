<?php
/**
 * author:liu.
 */

namespace Common\Validate;

class LoginValidate extends BaseValidate
{
    protected $rule = [
        'type' => 'existarray',
    ];
    private $arr= [1,2];


    protected  function existarray($value){

       if(!in_array($value,$this->arr)){
           $this->set_error('300101');
           return false;
       }

       return true;
    }


}