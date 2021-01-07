<?php
namespace Admin\Model;

/**
 * Class StrategyModel
 * @package Admin\Model
 */
class StrategyModel extends SystemModel
{
	protected $trueTableName = 'strategy';
	protected static $config = null;
	
	//所有分渠道配置项都是以STRATEGY_开头
	public $strategy_data = [
	];

	protected $_validate = array(
	    array('channel_id','require','请选择渠道名！'),
	);
	
	public $_auto		=	array(
	    array('create_time','time',self::MODEL_INSERT,'function'),
	    array('update_time','time',self::MODEL_INSERT,'function'),
	    array('update_time','time',self::MODEL_UPDATE,'function'),
	);
		
	/**
	 * 获取渠道策略
	 * @param  string   $channel_name        渠道名称
	 * @return  array   $strategy            渠道策略
	 */
	public function getValue($channel_name)
	{
	    $cachekey = $this->getCacheKey($channel_name);
	    $strategy = S($cachekey);
	    if(false===$strategy)
	    {
	        $strategy = $this->createStrategyCache($channel_name);
	    }
	    return $strategy;
	}
	
	/**
	 * 创建分渠道策略的缓存
	 * @param string $channel_name
	 */
	public function createStrategyCache($channel_name)
	{
	    $data = $this->where(['channel_name'=>$channel_name])->getField('name,value', true);
	    $data = !empty($data) ? $data : [];
	    $cachekey = $this->getCacheKey($channel_name);
	    S($cachekey, $data);
	    return $data;
	}
		
	/**
	 * 获取渠道策略缓存key
	 */
	protected function getCacheKey($channel_name)
	{
	    return "channel_strategy_".$channel_name;
	}

    public function createAllChannelStrategyCache()
    {
        $allChannel = D('Admin/SysChannel')->where(['status'=>1])->getField('name', true);
        $chunk = arr_chunk($allChannel);
        foreach ($chunk as $one)
        {
            $res = $this->where(['channel_name'=>['IN', implode(',', $one)]])->field('channel_name, name, value')->select();
            foreach ($res as $val)
            {
                $data[$val['channel_name']][$val['name']] = $val['value'];
            }
        }
        foreach ($allChannel as $chn)
        {
            $key = $this->getCacheKey($chn);
            !isset($data[$chn]) ? S($key, []) : S($key, $data[$chn]);
        }
        return true;
    }
    
	/**
	 * 删除数据时候重建缓存
	 */
	protected function _after_delete() 
	{
	    $channal_name = I('get.channel_name');
	    $this->createStrategyCache($channal_name);
	}

	/**
	 * 自动生成渠道对应的策略项
	 * @param  int      $channel_id    渠道id
	 * @param  string   $channel_name  渠道名称
	 */
	public function init($channel_id, $channel_name)
	{
	    $config = D('SysConfig')->getAll();
	    $prefixa = 'STRATEGY_';
	    foreach ($config as $k => $v)
	    {
	        if (false !== strpos($k, $prefixa))
	        {
	            $name = strtolower(substr($k, strpos($k, "_")+1));
	            $strategy[$name] = $v;
	        }else {
	            $strategy[strtolower($k)] = $v;
	        }
	    }
	    $data = $this->strategy_data;
	    $msg = [];
	    foreach($data as $value)
	    {
	        $default_value = isset($strategy[$value['name']]) ? $strategy[$value['name']] : $value['value'];
	        $msg[] = ['channel_id'=>$channel_id, 'channel_name'=>$channel_name, 'name'=>$value['name'], 'cname'=>$value['cname'], 'value'=>$default_value];
	    }
	    //缺失的配置项
	    $not_exist = [];
	    $has_update = [];
	    foreach($msg as $val)
	    {
	        $where = ['channel_id'=>$val['channel_id'], 'name'=>$val['name']];
	        $exist_strategy = $this->where($where)->find();
	        if(empty($exist_strategy))
	        {
	            $val['create_time'] = time();
	            $val['update_time'] = time();
	            $not_exist[] = $val;
	        } else if ($val['cname'] != $exist_strategy['cname']) {
	        	$exist_strategy['update_time'] = time();
	        	$exist_strategy['cname'] = $val['cname'];
	        	$has_update[] = $exist_strategy;
	        }
	    }
	    //若有缺失的配置项,则生成。此处为批量生成
	    if(!empty($not_exist))
	    {
	        $res = $this->addAll($not_exist);
	        if($res)
	            $this->createStrategyCache($channel_name);
	        else
	            $this->error('渠道策略新增失败');
	    }
	    if (!empty($has_update)) {
	    	foreach ($has_update as $value) {
	    		$res = $this->save($value);
	    		if (!$res) {
	    			break;
	    		}
	    	}
	    	if($res)
	            $this->createStrategyCache($channel_name);
	        else
	            $this->error('渠道策略更新失败');
	    }
	}
}