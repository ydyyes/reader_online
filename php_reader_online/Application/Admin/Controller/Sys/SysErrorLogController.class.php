<?php
/**
 * 显示一条系统异常的错误详情
 * @author shuhai
 */
namespace Admin\Controller\Sys;
use Admin\Controller\SystemController;

class SysErrorLogController extends SystemController
{
	public $model = 'SysErrorLog';
	
	function view()
	{
		header("Content-Type:text/html; charset=utf-8");

		$id = I("get.id");
		
		$find = D("SysErrorLog")->find($id);
		if(empty($find))
			$this->error("记录不存在");
		
		$find["backtrace"] = unserialize($find["backtrace"]);
		$find["env"] = unserialize($find["env"]);

		//@todo 做一个比较好看的Tab页来展示数据
		dump($find);
	}
}