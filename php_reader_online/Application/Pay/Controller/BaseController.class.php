<?php
/**
 * User:Xxx
 */

namespace Pay\Controller;


class BaseController
{
    protected $params = [];



   public function setParameter($parameter, $parameterValue){
       $this->params[$parameter] = $parameterValue;
    }

    public function MakeSign($Obj,$ordered = '')
    {
        foreach ($Obj as $k => $v){
            $Parameters[$k] = $v;
        }
        ksort($Parameters);
        $String = $this->ToUrlParams($Parameters);
        if($ordered)
            $String = $String.C('ordered_key');
        else
            $String = $String.C('key');

        $result_ = md5($String);

        return $result_;
    }

    function checkSign($data)
    {
        if(!isset($data['sign'])){
            return FALSE;
        }
        $sign = $this->MakeSign($data);


        if ($sign == $data['sign']) {
            return TRUE;
        }
        return FALSE;
    }


    public function ToUrlParams($Parameters)
    {
        $buff = "";
        foreach ($Parameters as $k => $v)
        {
            if($k != "sign" && $v != "" && !is_array($v)){
                $buff .= $k . "=" . $v . "&";
            }
        }

        $buff = trim($buff, "&");
        return $buff;
    }

}