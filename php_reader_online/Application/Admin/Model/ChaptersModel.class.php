<?php
namespace Admin\Model;

/**
 * Class ChaptersModel
 * @package Admin\Model
 */
class ChaptersModel extends SystemModel
{
	protected $trueTableName = 'xs_chapters';

	public function getCache($_id, $serial=0)
	{
		$redis = \Think\Cache::getInstance('redis');
		$key = $this->getChapterCacheKey($_id);
		$data = [];
		if ($serial > 0)
		{
			$chapter = $redis->hget($key, $serial);
			$data[$serial] = json_decode($chapter, true);
		} else {
			$data = $redis->hgetall($key);
			foreach ($data as $k => $val)
			{
				$data[$k] = json_decode($val, true);
			}
		}
		return $data;
	}

	public function createCache($nid = 0)
	{
		if (empty($nid))
		{
			$nids = D('Admin/Novels')->where(['status'=>NovelsModel::STATUS_ON])->getField('id', true);
		} else {
			$nids = [$nid];
		}

		$redis = \Think\Cache::getInstance('redis');
		foreach ($nids as $nid)
		{
			$data = $this->where(['nid'=>$nid])->field(['id', 'nid', '_id', 'chid', 'serial', 'title', 'link'])->select();
			$_id = array_column($data, '_id')[0];
			$key = $this->getChapterCacheKey($_id);
			$redis->del($key);
			if ($data)
			{
				foreach ($data as $val)
				{
					$redis->hset($key, $val['serial'], json_encode($val));
				}
			}
			
		}
	}

	public function statusWithNovels($nid, $status)
	{
		if ($status == NovelsModel::STATUS_ON)
		{
			$this->createCache($nid);
		} else {
			$redis = \Think\Cache::getInstance('redis');
			$_id = D('Admin/Novels')->where(['id'=>$nid])->getField('_id');
			$key = $this->getChapterCacheKey($_id);
			$redis->del($key);
		}
	}

	public function getChapterCacheKey($_id)
	{
		return "x_chapters_" . $_id;
	}
}