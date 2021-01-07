<?php
namespace Admin\Model;

/**
 * Class UpgradeModel
 * @package Admin\Model
 */
class UpgradeModel extends SystemModel
{
	protected $trueTableName = 'xs_upgrade';

	protected $_validate = array(
	    array('version','require','版本号不能为空！'),
	);
	
	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
        array('update_at','time',self::MODEL_INSERT,'function'),
        array('update_at','time',self::MODEL_UPDATE,'function'),
    );

    const STATUS_OFF = 0;
    const STATUS_ON = 1;

    public $status = [
        self::STATUS_ON => '上架',
        self::STATUS_OFF => '下架',
    ];

    public function getValue($channel)
	{
	    $redis = \Think\Cache::getInstance('redis');
	    $data = $redis->hget($this->getCacheKey(), $channel);
	    return $data ? json_decode($data, true): [];
	}

	public function createCache()
    {
        $data = $this->where(['status' => self::STATUS_ON])->field(
            ['id', 'md5', 'version','forced_updating', 'apk_url', 'chn_id', 'target_size', 'update_log']
        )->select();
        $channels = D('Admin/SysChannel')->getField('id,name', true);
        $redis = \Think\Cache::getInstance('redis');
        $key = $this->getCacheKey();
        $redis->del($key);
        foreach ($data as $val)
        {
            $chnIds = explode(',', trim($val['chn_id'], ','));
            unset($val['chn_id']);
            foreach ($chnIds as $chnId)
            {
                $tmp[$channels[$chnId]][] = $val;
            }
        }
        if (!empty($tmp))
        {
            foreach ($tmp as $channel => $batch)
            {
                $redis->hset($key, $channel, json_encode($batch));
            }
        }
    }

    /*
	 * 获取缓存key
	 */
	public function getCacheKey()
	{
	    return "upgrade_hash";
	}
}