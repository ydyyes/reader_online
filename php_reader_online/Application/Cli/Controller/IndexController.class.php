<?php
namespace Cli\Controller;

class IndexController extends ClibaseController
{
	public function index()
	{
		$this->hello();
	}
	
	protected function hello()
	{
		$this->clear();
		echo "+---------------------------------------------------------------------+\n";
		echo "+ cli mode useage\n";
		echo "+ php cli.php 控制器/方法 参数1 参数值1 参数2 参数值2\n";
		echo "+---------------------------------------------------------------------+\n";
		echo "+ 生成后台管理菜单，配置文件位于Application/Admin/Conf/menu.php\n";
		echo "  php cli.php menu/make\n";
		exit;
	}
}
