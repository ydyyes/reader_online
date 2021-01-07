<?php
/**
 * Redis异步模型，本类可以拦截模型的写入操作，将数据写入Redis，可以在异步任务中将数据写入模型
 * 
 * @author shuhai
 */
namespace Common\Model;
use Think\Model;
use Think\Cache;
use Think\Log;

class RedisLazzyModel extends Model
{
	protected $redis;
    protected $autoCheckFields = false;
	
	function connect()
	{
		try {
			$config = array();
			$this->redis = Cache::getInstance('redis');
		} catch (\Exception $e){
			Log::write($e->getMessage(), Log::EMERG);
			return false;
		}
	}
	
	/**
	 * 拦截入库操作
	 */
	function _before_insert($data, $options)
	{
		if(false === $this->connect())
			return false;
		
		$args = func_get_args();
		$args = serialize($args);
		
		if(empty($options))
			$options = $this->_parseOptions();
		
		$key = $options['model'] ? $options['model'] : __CLASS__;
		$this->redis->lpush($key, $args);

		//返回false将拦截add的操作
		return false;
	}
	
	/**
	 * 延迟写入
	 * 每次写入1000条
	 * 
	 * @example
	 * class ActlogModel extends RedisLazzyModel
	 * D("Actlog")->lazzy_insert();
	 * (new RedisLazzyModel('Actlog') )->lazzy_insert($num=1000);
	 */
	function lazzy_insert($num=1000)
	{
		if(false === $this->connect())
			return false;
		
		$options = $this->_parseOptions();
		$key = $options['model'] ? $options['model'] : __CLASS__;
		
		$llen = $this->redis->llen($key);
		$num = $num >= $llen ? $llen : $num;
		
		while($num > 0)
		{
			$num --;
			$data = $this->redis->rpop($key);
			$result = call_user_func_array(array($this->db, 'insert'), (array)unserialize($data));
		}

		return $result;
	}
}