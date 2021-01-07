<?php
namespace Admin\Model;

/**
 * Class StatisticDloadtimesModel
 * @package Admin\Model
 */
class StatisticDloadtimesModel extends SystemModel
{
	protected $trueTableName = 'xs_statistic_dloadtimes';

	public function addToQueue(array $data)
	{
		$redis = \Think\Cache::getInstance();
		$redis->rpush($this->getCacheKey(), json_encode($data));
	}

	public function getCacheKey()
	{
		return "sta_dloadtimes";
	}
}