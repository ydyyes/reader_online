<?php
namespace Admin\Controller\Sys;
use Admin\Controller\SystemController;

class SysVersionController extends SystemController
{
	public $model = "SysVersion";
	public $not_allow_action = array("foreverdelete", "delete");
	
	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
	}
	
	public function channel_version()
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
	}
	
}