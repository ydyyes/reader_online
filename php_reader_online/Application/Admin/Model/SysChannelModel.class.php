<?php
namespace Admin\Model;

class SysChannelModel extends SystemModel
{
	protected $trueTableName = "sys_channel";
	protected $_pk = 'id';
	protected static $channel_id_name = false;
	
	public $_auto		=	array(
			array('create_at','time',self::MODEL_INSERT,'function'),
			array('admin_id','admin_id',self::MODEL_INSERT,'function'),
	);
	
	protected $_validate = array(
			array('name','','渠道名称已经存在！',self::MODEL_INSERT,'unique',1),
			array('name','require','英文名称不能为空'),
			array('cname','require','中文名称不能为空'),
	);

	/**
	 * 获取当前登录者渠道名称
	 * 
	 * @param int $channelid 渠道id
	 * @author allenqin<allenqinhai@gmail.com>
	 */
	public function getChannelName($channelid = NULL)
	{
		$map['id'] = $channelid ? $channelid : admin_channel_id();
		return $this->where($map)->cache(true, 3600)->getField('name');
	}

	public function getChannelIdByName($channel)
	{
		return $this->where(['name'=>$channel])->cache(true, 3600)->getField('id');
	}

    /**
     * 获得渠道id和渠道缓存
     */
    public function getChannelList($alia)
    {
        $key = $this->getChannelListKey();
        $redis = \Think\Cache::getInstance('redis');
        if (empty($alia))
        {
            $value = $redis->hgetall($key);
        } else {
            $value = $redis->hget($key, $alia);
        }
        return $value;
    }

	/**
	 * 创建渠道id和渠道缓存
	 */
	public function createChannelList()
	{
		$key = $this->getChannelListKey();
		$data = $this->where(['status'=>1])->getField('hash, name', true);
        $redis = \Think\Cache::getInstance('redis');
        $redis->del($key);
		foreach ($data as $h => $n)
        {
            $redis->hset($key, $h, $n);
            $redis->hset($key, $n, $h);
        }
		return true;
	}
	
	/**
	 * 缓存渠道id和渠道key
	 */
	public function getChannelListKey()
	{
		return "wd_channel_list";
	}
}