<?php
namespace Admin\Model;
use Think\Model;

class SysVersionChannelModel extends Model
{
	protected $trueTableName = "sys_version_channel";
	protected $_status = ['0'=>'禁用', '1'=>'启用'];
	protected $_pk = 'id';
	
	//自动完成
	public $_auto		 =	array(
			array('create_at','time',self::MODEL_INSERT,'function'),
			array('create_admin_id','admin_id',self::MODEL_INSERT,'function'),
	);
	
	protected $_validate = array(
			array('version_type',array(1, 2, 3),'发布类型不正确！',2,'in'),
			array('version_id','uniqueChannelVersion','该版本已经添加',1,'callback',1),
	);

	public function getType($type)
	{
		return "";
	}
	
	/**
	 * 判断渠道是否已经添加了此版本应用
	 * 
	 * @return boolean
	 * @author allenqin<allenqinhai@gmail.com>
	 */
	public function uniqueChannelVersion()
	{
		$map = array(
				'version_id'    => $_REQUEST['version_id'],
				'channel_id'	=> $_REQUEST['channel_id'],
		);
		
		$id = $this->where($map)->count();
		
		return $id ? false : true;
	}
	
	/**
	 * 获取渠道版本的使用状态
	 * 
	 * @param $status 状态值
	 * @see SystemModel::getStatus()
	 */
	public function getStatus($status)
	{
		return $this->_status[$status];	
	}
}