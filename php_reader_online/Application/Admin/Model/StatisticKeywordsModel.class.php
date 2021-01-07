<?php
namespace Admin\Model;

/**
 * Class StatisticKeywordsModel
 * @package Admin\Model
 */
class StatisticKeywordsModel extends SystemModel
{
	protected $trueTableName = 'xs_statistic_keywords';

	public function addToQueue(array $data)
	{
		$redis = \Think\Cache::getInstance();
		$redis->rpush($this->getCacheKey(), json_encode($data));
	}

	public function getCacheKey()
	{
		return "sta_keywords";
	}
}