<?php
namespace Common\Model;
use Think\Model;

/**
 * 系统参数配置，简单的K/V实现
 * @uses D("SysConfig")->getValue('SOME_CONF');
 * @author shuhai
 */
class SysConfigModel extends Model
{
	protected $trueTableName = "sys_config";
	public $cachekey_name = "sys_config_key";

	protected static $config = null;

	public $type = [
			"input"		=>"文本",
			"select"	=>"下拉框",
			"radio"		=>"单选框",
			"checkbox"	=>"多选框",
			"textarea"	=>"多行文本",
	];
	
	public $validate_type = [
			"string"		=>"文字",
			"json"			=>"JSON对象",
			"email"			=>"邮箱地址",
			"alphanumeric"	=>"字母、数字、下划线",
			"phone"			=>"电话",
			"lettersonly"	=>"字母",
			"url"			=>"链接地址",
			"digits"		=>"整数",
			"number"		=>"浮点数",
	];
	
	public $_auto		=	array(
			array('create_at','time',self::MODEL_INSERT,'function'),
			array('update_at','time',self::MODEL_UPDATE,'function'),
	);
	
	/**
	 * 获取所有系统配置项
	 * @return array array($field=>$value)
	 */
	function getAll()
	{
	    if(!is_null(self::$config))
	        return self::$config;

		$config = S($this->cachekey_name);
		self::$config = $config = $this->format($config);
		return $config;
	}

	/**
	 * 获取系统配置项
	 * @param string $field     获取的key
	 * @param string $default   无返回值的时候，使用的默认值
	 * @return mixed $value array($field=>$value)
	 */
	function getValue($field, $default=null)
	{
		$field  = strtoupper($field);
		$config = $this->getAll();
		return isset($config[$field]) ? $config[$field] : $default;
	}
	
	/**
	 * 重建缓存
	 */
	function flushCache()
	{
		$this->makeAll();
	}
	
	public function makeAll()
	{
	    $config = $this->where(['status'=>1])->getField("name, value", true);
	    $key = $this->cachekey_name;
	    $is_cache = S($key, $config);
	    return (1==$is_cache) ? true : false;
	}
	
	/**
	 * 数据发生变动，则清空并重建缓存
	 * @see \Think\Model::_after_update()
	 */
	protected function _after_update($data, $options)
	{
		$this->flushCache();
	}
	
	protected function _after_insert($data, $options)
	{
		$this->flushCache();
	}
	
	/**
	 * 数据取出为数组类型
	 * @param array $config
	 * @return array
	 */
	protected function format($config)
	{
		$newconfig = [];
		foreach ($config as $k => $v)
		{
			$c = substr($v, 0, 1);
			if(in_array($c, ["{", "["]) && $json = json_decode($v, true))
				$config[$k] = $json;
			
			$newconfig[strtoupper($k)] = $config[$k];
		}

		return $config;
	}
	
	/**
	 * 数据是否是合法的json串
	 * @param string $data
	 * @return boolean
	 */
	function is_json($data)
	{
		json_decode($data);
		return json_last_error() == 0;
	}
	
	/**
	 * 初始化配置项，可以将数据导入配置表
	 * @param array $config
	 */
	function import(array $config)
	{
		$this->flushCache();

		$old_config = $this->getAll();
		foreach ($config as $c => $v)
		{
			if(isset($old_config[$c]))
				continue;

			$data = isset($v["name"]) ? $v : ["name"=>$c, "value"=>$v];
			$this->create($data);
			$this->add();
		}
		
		$this->flushCache();
	}
}
