<?php
namespace Admin\Model;

/**
 * Class AdsModel
 * @package Admin\Model
 */
class AdModel extends SystemModel
{
	protected $trueTableName = 'xs_ads';

	protected $_validate = array(
	    array('title','require','标题不能为空！'),
	);
	
	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
        array('update_at','time',self::MODEL_INSERT,'function'),
        array('update_at','time',self::MODEL_UPDATE,'function'),
    );

    const STATUS_OFF = 0;
    const STATUS_ON = 1;

    const LOCATION_OPEN_APP = 1;
    const LOCATION_NOVEL_END = 2;

    public $status = [
        self::STATUS_ON => '上架',
        self::STATUS_OFF => '下架',
    ];

    public $location = [
        self::LOCATION_OPEN_APP => '开屏',
        self::LOCATION_NOVEL_END => '文章末尾'
    ];

    public function getData($channel, $vcode)
    {
        $redis = \Think\Cache::getInstance('redis');
        $key = $this->getCacheKey($channel, $vcode);
        $info = $redis->hgetall($key);
        $data = [];
        if (!empty($info))
        {
            foreach ($info as $val)
            {
                $data[] = json_decode($val, true);
            }
        }
        return $data;
    }

    public function createCache($id = 0)
    {
        $versionChannelModel = D('Admin/SysVersionChannel');
        $channelModel = D('Admin/SysChannel');
        $instance = \Think\Cache::getInstance('redis');
        $fields = ['id','title', 'link', 'location', 'img', 'status', 'chn_v_ids'];
        if ($id > 0)
        {
            $data = $this->where(['id'=>$id])->field($fields)->select();
        } else {
            $data = $this->where(['status'=>self::STATUS_ON])->field($fields)->select();
            $allChnvIds = $this->getField('chn_v_ids', true);
            $tmp = [];
            foreach ($allChnvIds as $v)
            {
                $chnvIds = explode(',', trim($v, ','));
                $versionChannel = $versionChannelModel->where(['id'=>['IN', $chnvIds]])->getField('id, channel_id,version_code', true);
                $channels = $channelModel->where(['id'=>['IN', array_column($versionChannel, 'channel_id')]])->getField('id,name', true);
                foreach ($versionChannel as $v2)
                {
                    $k = $this->getCacheKey($channels[$v2['channel_id']], $v2['version_code']);
                    if (in_array($k, $tmp))
                    {
                        continue;
                    }
                    $instance->del($k);
                    $tmp[] = $k;
                }
            }
        }
        if (!empty($data))
        {
            foreach ($data as $val)
            {
                $val['img'] = cdn('ATTACH') . $val['img'];
                if (!empty($val['chn_v_ids']))
                {
                    $chnvIds = explode(',', trim($val['chn_v_ids'], ','));
                    unset($val['chn_v_ids']);
                    $versionChannel = $versionChannelModel->where(['id'=>['IN', $chnvIds]])->getField('id, channel_id,version_code', true);
                    $channels = $channelModel->where(['id'=>['IN', array_column($versionChannel, 'channel_id')]])->getField('id,name', true);
                    if ($val['status'] > 0)
                    {
                        unset($val['status']);
                        foreach ($versionChannel as $vc)
                        {
                            $channel = $channels[$vc['channel_id']];
                            $key = $this->getCacheKey($channel, $vc['version_code']);
                            $instance->hset($key, $val['id'], json_encode($val));
                        }
                    } else {
                        unset($val['status']);
                        foreach ($versionChannel as $vc)
                        {
                            $channel = $channels[$vc['channel_id']];
                            $key = $this->getCacheKey($channel, $vc['version_code']);
                            $instance->hdel($key, $val['id']);
                        }
                    }
                }
            }
        }
    }

    public function beforeUpdateDel($id)
    {
        if ($id > 0)
        {
            $versionChannelModel = D('Admin/SysVersionChannel');
            $channelModel = D('Admin/SysChannel');
            $instance = \Think\Cache::getInstance('redis');
            $chnvIds = $this->where(['id'=>$_POST['id']])->getField('chn_v_ids');
            $chnvIds = explode(',', trim($chnvIds, ','));
            $versionChannel = $versionChannelModel->where(['id'=>['IN', $chnvIds]])->getField('id, channel_id,version_code', true);
            $channels = $channelModel->where(['id'=>['IN', array_column($versionChannel, 'channel_id')]])->getField('id,name', true);
            foreach ($versionChannel as $vc)
            {
                $channel = $channels[$vc['channel_id']];
                $key = $this->getCacheKey($channel, $vc['version_code']);
                $instance->hdel($key, $id);
            }
        }
    }

    /**
     * 获取缓存key
     */
    public function getCacheKey($channel, $vcode)
    {
        return sprintf("x_ad_%s_%d", $channel, $vcode);
    }
}