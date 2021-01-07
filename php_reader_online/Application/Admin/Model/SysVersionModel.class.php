<?php
namespace Admin\Model;
use Think\Model;

class SysVersionModel extends Model
{
	protected $trueTableName = "sys_version";
	
	protected $_pk = 'id';
	
	public $_auto  = array(
			array('create_at','time',self::MODEL_INSERT,'function'),
			array('admin_id','admin_id',self::MODEL_INSERT,'function'),
	);
	
	/**
	 * 获取版本号名称
	 *
	 * @param int $vcode 版本号
	 * @param int $product  产品类型
	 * @author allenqin<allenqinhai@gmail.com>
	 */
	public function getVersionName($vcode, $product)
	{
		if(!$vcode || !$product)
			return '未知版本';
		
		$version_name = $this->where(array('version_code'=>$vcode, 'version_type'=>$product))->cache(false)->getField('version_name');
		return $version_name ? $version_name : '未知版本';
	}
	
	public function getVersionList($product)
	{
		if(!$product)
			return '未知版本';
	
		$version = $this->where(array('version_type'=>$product))->cache(false)->getField('version_code, version_name', true);
		return $version;
	}
}