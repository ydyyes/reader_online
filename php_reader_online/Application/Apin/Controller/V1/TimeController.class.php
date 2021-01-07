<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Think\Controller;

class TimeController extends Controller
{
    public function index(){
        $time =microtime();
        $time = explode(' ',$time);
        $millisecond = $time[0];
        $m_t = substr($millisecond,strpos($millisecond,'.')+1,3);
        die($time[1].$m_t);
    }


}