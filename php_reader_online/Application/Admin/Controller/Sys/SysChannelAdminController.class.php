<?php
namespace Admin\Controller\Sys;
use Admin\Controller\SystemController;

class SysChannelAdminController extends SystemController
{
	public $model = "SysChannel";
	
	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
	}
	
	function add()
	{
		$channel_id = I("channel_id", "0", "intval");
		if(empty($channel_id))
			$this->error("渠道参数丢失");
		
		$name = 'Admin';
		//列表过滤器，生成查询Map对象
		$map = array();
		$this->_filter ( $map );
		$model = D ($name);
		if (! empty ( $model )) {
			$this->_list ( $model, $map );
		}
		
		$channel_admin = D("SysChannelAdmin")->where(array("channel_id"=>$channel_id))->getField("admin_id,administrator");
		$this->assign ('channel_admin', $channel_admin);
		$this->assign ('channel_id', $channel_id);
		$this->assign ('map', $map);
		$this->display ();
	}
	
	function grant()
	{
		$channel_id = I("channel_id", "0", "intval");
		$admin_id = I("admin_id", "0", "intval");
		$administrator = I("administrator", "0", "intval");
		$grant = I("grant", "offgrant", "trim");
		
		if(empty($admin_id) || empty($channel_id))
			$this->error("参数不正确，请重新登陆打开页面再提交");
		
		if(!$admin = D("Admin")->where(array("id"=>$admin_id))->find())
			$this->error("指定的管理员不存在");
		if(!$channel = D("SysChannel")->where(array("id"=>$channel_id))->find())
			$this->error("指定的渠道不存在");
		
		$model = D("SysChannelAdmin");
		$data = array("channel_id"=>$channel_id, "admin_id"=>$admin_id);
		
		//一个运营人员只能管理一个渠道
		if($grant == "ongrant")
		{
			$find = array("channel_id"=>array("neq", $channel_id), "admin_id"=>$admin_id);
			$find = $model->where($find)->find();
			if(!empty($find))
				$this->error("该运营人员已经授权了渠道，不能重复授权");
		}
		
		$model->where($data)->delete();
		
		if($grant == "ongrant")
		{
			if(!empty($administrator))
				$data["administrator"] = $administrator;
			
			$rel = $model->data($data)->add();
			
			if($rel !== false){
				D("Admin")->data(array("channel_id"=>$channel_id))->where(array("id"=>$admin_id))->limit(1)->save();
				$this->success("授权成功");
			}else{
				$this->error("系统错误，授权失败");
			}
		}else{
			D("Admin")->data(array("channel_id"=>0))->where(array("id"=>$admin_id))->save();
			$this->success("取消授权成功");
		}
	}
	
	function delete()
	{
		$this->error("渠道不允许删除");
	}
	
	function foreverdelete()
	{
		return $this->delete();
	}
}