<?php
namespace Admin\Controller\Sys;
use Admin\Controller\SystemController;

class SysVersionChannelController extends SystemController
{
	const VERSION_TYPE = 'version_type';
	public $model = "SysChannel";
	public $not_allow_action = ["foreverdelete", "delete"];
	
	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
	}
	
	function edit()
	{
		$this->model = "SysVersionChannel";
		parent::edit();
	}

	/**
	 * version_channel列表 
	 */
	public function view_channel()
	{
		$this->model = "SysVersionChannel";

		$map['channel_id'] = I('get.id');

		$model = D('SysVersionChannel');
		if (! empty ( $model )) {
			$this->_list ( $model, $map );
		}

		$this->assign ('map', $map);
		$this->display ('list');
	}
	
	public function insert()
	{
		$this->model = "SysVersionChannel";
		
		$this->fix_version_channel_code();
		parent::insert();
	}
	
	public function update()
	{
		$this->model = "SysVersionChannel";
		
		$this->fix_version_channel_code();
		parent::update();
	}
	
	protected function fix_version_channel_code()
	{
		$version_id = I("post.version_id");
		$_POST["version_code"] = D("SysVersion")->where(array("id"=>$version_id))->getField("version_code");
	}
	
	/**
	 * 获取不同产品下的版本列表
	 * 
	 * @author allenqin<allenqinhai@gmail.com>
	 */
	public function getVersion()
	{
		$version_type = I('get.version_type', '1');
		
		$versionList = D('SysVersion')->where(array('version_type'=>$version_type))->getField("id,version_name");
		
		if ($versionList) 
		{
			foreach ($versionList as $key=>$value)
			{
				$tmp[] = '["'.$key.'", "'.$value.'"]';
			}
			
			$versionString = '['.implode(',', $tmp).']';
			
			echo $versionString;			
			exit();
		}else{
			return false;
		}
	}
}