<?php
namespace Test\Controller;

class IndexController extends BaseController
{
	function index()
	{
		$this->clear();
		echo "+-------------------------------------------------------PowerBy Shuhai+\n";
		echo "+---------------------------------------------------------------------+\n";
		echo "+ Test mode useage\n";
		echo "+ php test Controller 测试指定的控制器\n";
		echo "+ php test all 自动测试所有的测试模块\n";
		exit;
	}

	function all()
	{
		$file = glob(__DIR__."/Test*.php");
		foreach ($file as $api)
		{
			$apiname = basename(str_replace([".class.php", ".php"], '', $api));
			$class = __NAMESPACE__."\\".$apiname;
			
			$this->runtest($class);
		}
	}
}