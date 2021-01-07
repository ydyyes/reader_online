<?php
namespace Test\Controller;

/**
 * Redis及驱动测试工具
 * @author shuhai
 */
class TestRedisController extends BaseController
{
    protected $pool;
    protected $key;
    protected $value;
    protected $array;
    
	public function _init()
	{
	    $this->pool["redis"] = \Think\Cache::getInstance('redis');
	    $this->pool["redisd"] = \Think\Cache::getInstance('redisd');
	    
	    $this->key = time();
	    $this->value = time();
	    $this->array = ["day"=>date("Y-m-d H:i:s"), "time"=>time()];
	}
	
    /**
	 * 测试redis驱动
	 * @author shuhai
	 */
	function test_set_get()
	{
	    $this->_init();
	    
	    $res = $this->pool["redis"]->set($this->key, $this->value);
	    if(empty($res))
	        return false;
	    
        $res = $this->pool["redis"]->get($this->key);
	    return $res == $this->value;
	}
    
    /**
	 * 测试redis gzip压缩
	 * @author shuhai
	 */
	function test_gzip()
	{
	    $this->_init();
	    
	    $data = gzencode(json_encode($this->array));
	    $res = $this->pool["redis"]->set($this->key, $data);
	    if(empty($res))
	        return false;
	    
        $res = $this->pool["redis"]->get($this->key);
	    $res = json_decode(gzdecode($res), true);

	    return $res["time"] == $this->array["time"];
	}
	
	/**
	 * 测试redis gzcompress
	 * @author shuhai
	 */
    function test_gzcompress()
	{
        $this->_init();
	    
	    $data = gzcompress(json_encode($this->array));
	    $res = $this->pool["redis"]->set($this->key, $data);
	    if(empty($res))
	        return false;
	    
        $res = $this->pool["redis"]->get($this->key);
	    $res = json_decode(gzuncompress($res), true);

	    return $res["time"] == $this->array["time"];
	}
	
	/**
	 * 测试redis 读写 array
	 * @author shuhai
	 */
    function test_array()
	{
        $this->_init();
	    
	    $res = $this->pool["redis"]->set($this->key, $this->array);
	    if(empty($res))
	        return false;
	    
        $res = $this->pool["redis"]->get($this->key);

	    return $res == $this->array;
	}
	
	/**
	 * 测试redis 读写 object
	 * @author shuhai
	 */
    function test_object()
	{
	    $res = $this->pool["redis"]->set($this->key, serialize($this));
	    if(empty($res))
	        return false;
	    
        $res = $this->pool["redis"]->get($this->key);
        $res = unserialize($res);

	    return method_exists($res, __FUNCTION__);
	}
	
    /**
	 * 测试redis + mysql query cache
	 * @author shuhai
	 */
    function test_mysql_query_cache()
	{
	    $query = M("think_admin")->find();
	    $cache = M("think_admin")->cache($this->key)->find();

	    return $query === $cache;
	}
	
    /**
	 * 测试redis ttl
	 * @author shuhai
	 */
    function test_ttl()
	{
	    $query = M("think_admin")->find();
	    $cache = M("think_admin")->cache($this->key)->find();

	    return $query === $cache;
	}
}