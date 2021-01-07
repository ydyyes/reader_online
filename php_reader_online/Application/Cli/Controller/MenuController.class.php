<?php
namespace Cli\Controller;

use Common\Model\SysConfigModel;

/**
 * 生成后台菜单，系统配置项
 * 配置文件位置 Admin/Conf/menu.php
 * 系统配置文件位置 Admin/Conf/sys_config.php
 * @author shuhai
 */
class MenuController extends ClibaseController
{
	function make()
	{
		$this->make_config();
		$this->make_menu();
	}
	
	protected function make_config()
	{
		$config= APP_PATH."Admin/Conf/sys_config.php";
		$admin = @include $config;
		if(empty($admin))
			$this->printf("no system config item in %s", $config);
		
		foreach ($admin as $k=>$value)
		{
			list($comment, $v, $option) = $value;

			$option = (array)$option;
			$option["name"]    = $k;
			$option["comment"] = $comment;
			$option["value"]   = $v;
			
			$admin[$k] = $option;
		}

		(new SysConfigModel())->import($admin);
		(new SysConfigModel())->getAll();
	}

	protected function make_menu()
	{
		$config= APP_PATH."Admin/Conf/menu.php";
		$admin = @include $config;
		if(empty($admin))
			$this->printf("no menu find in %s", $config);
		
		$node = D("Admin/Node");
		$nodeGroup = D("Admin/NodeGroup");
		foreach ($admin as $name=>$menu)
		{
			$gid = $nodeGroup->where(["name"=>$name])->getField("id");
			if(empty($gid))
				$gid = $nodeGroup->data(["name"=>$name, "status"=>1])->add();
			
			if(!empty($gid))
			{
				foreach ($menu as $controller => $nodeMenu)
				{
					list($name, $action, $params) = $nodeMenu;

					$controller = trim($controller);
					$action = empty($action) ? "index" : $action;
					$params = empty($params) ? "" : $action;

					$nid = $node->where(["name"=>$controller, "action"=>$action, "group_id"=>$gid])->getField("id");
					if(empty($nid))
					{
						$node->data(["name"=>$controller, "title"=>$name, "action"=>$action, "params"=>$params, "group_id"=>$gid, "pid"=>1, "level"=>2, "status"=>1])->add();
						$this->printf("%s:%s added", $name, $controller);
					}
				}
			}
		}
	}
}