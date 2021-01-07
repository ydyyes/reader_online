<?php
namespace Common\Controller;
use Think\Controller;

class CommonController extends Controller
{
	protected $uc;
	protected $uid = 0;
	
	function _initialize()
	{
		//开发模式下，使用Whoops打印错误堆栈
		if (APP_DEBUG && class_exists('\Whoops\Run'))
		{
			$whoops = new \Whoops\Run;
			$whoops->pushHandler(new \Whoops\Handler\PrettyPageHandler);
			$whoops->register();
		}
		
		if(method_exists($this, '_init'))
			$this->_init();

	}
	
	protected function _init(){}
}