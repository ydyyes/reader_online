<?php
namespace Admin\Model;
use Think\Model;

class SysChannelPowerModel extends Model
{
	protected $trueTableName = "sys_channel_power";
	protected $_pk = 'id';
	
	/**
	 * 获取管理员授权的渠道或者cp
	 * 
	 * @param mixed $admin_id
	 */
	function getGrantedChannel($admin_id=null)
	{
		$admin_id = isset($admin_id) ? $admin_id : admin_id();
		$result = $this->where(["admin_id"=>$admin_id])->getField('memo');
		
		$result = ($result = json_decode($result, true)) ? $result : ["qd"=>[], "cp"=>[]];
		$id = explode(",", join(",", $result));
		
		//超级管理员可以管理所有数据
		$map = ["status"=>1, "id"=>["in", $id]];
		if(1 == $admin_id)
			$map = ["status"=>1];
		
		$channel = D("SysChannel")->where($map)->getField('id, name', true);
		return $channel;
	}
}