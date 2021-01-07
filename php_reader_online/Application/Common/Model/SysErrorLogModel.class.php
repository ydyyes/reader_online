<?php
namespace Common\Model;
use Think\Model;

/**
 * 系统错误记录到系统后台进行展示，可以记录一些附加变量
 * D("SysErrorLog")->setVar('upload_info', $info)->log("文件上传失败", "EMERG", true, true);
 * @author shuhai
 */
class SysErrorLogModel extends Model
{
	protected $variables_log = [];
	
	protected $trueTableName = 'think_sys_error_log';
	protected $tablePrefix   = '';
	
	protected $_auto = array(
			array('status', '0'),
			array('create_time','time', self::MODEL_INSERT,'function'),
			array('update_time','time', self::MODEL_UPDATE,'function'),
	);
	
	function setvar($k, $v)
	{
		$this->variables_log[$k] = $v;
		return $this;
	}
	
	/**
	 * 记录一条错误信息
	 * @param string $message  错误消息
	 * @param string $level    错误级别
	 * @param string $trace    是否存储相关堆栈
	 * @param string $env      是否存储相关环境变量
	 * @return true
	 */
	function log($message, $level="EMERG", $trace=true, $env=true)
	{
		$g = $GLOBALS;
		unset($g["GLOBALS"]);
		
		$url  = $_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"];
		$env  = $env ? serialize($g) : '';
		$backtrace = $trace ? serialize(debug_backtrace(null, 6)) : '';
		
		//如果有需要直接记录的变量
		if(count($this->variables_log) > 0)
		{
			$env  = $env ? serialize(array_merge($g, ["variables_log"=>$this->variables_log])) : serialize($this->variables_log);
			$this->variables_log = [];
		}
		
		$data = ["url"=>$url, "env"=>$env, "msg"=>$message, "level"=>$level, "backtrace"=>$backtrace];

		$this->create($data);
		$this->add();
		return true;
	}
}