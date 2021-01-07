<?php
namespace Admin\Model;

/**
 * Class StatisticReadtimesModel
 * @package Admin\Model
 */
class StatisticReadtimesModel extends SystemModel
{
	protected $trueTableName = 'xs_statistic_readtimes';

	public function addToQueue(array $data)
	{
		$redis = \Think\Cache::getInstance();
		$redis->rpush($this->getCacheKey(), json_encode($data));
	}

	public function getCacheKey()
	{
		return "sta_readtimes";
	}

	public function setUniq($username, $_id)
	{
		$key = $this->getUserUniqKey($username, $_id);
		if (false === S($key))
		{
			S($key, 1, strtotime('tomorrow') - time());
			return true;
		}
		return false;
	}

	public function getUserUniqKey($username, $_id)
	{
		return "rts_uniq_" . md5($username . $_id);
	}

	public function setShelfUniq($username, $_id)
	{
		$key = $this->getShelfUniqKey($username, $_id);
		if (false === S($key))
		{
			S($key, 1);
			return true;
		}
		return false;
	}

	public function getShelfUniqKey($username, $_id)
	{
		return "shelf_uniq_" . md5($username . $_id);
	}
}