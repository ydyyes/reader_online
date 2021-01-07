<?php
namespace Admin\Model;

/**
 * Class UserPaidLogModel
 * @package Admin\Model
 */
class UserPaidLogModel extends SystemModel
{
	protected $trueTableName = 'xs_user_paid_log';

	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
	);

	const PRODUCT_TYPE_DAY30 = 1;
	const PRODUCT_TYPE_DAY180 = 2;
	const PRODUCT_TYPE_DAY365 = 3;

	const TYPE_MEMBER = 1;
	const TYPE_GAME = 2;

	public $days = [
		self::PRODUCT_TYPE_DAY30 => 30,
		self::PRODUCT_TYPE_DAY180 => 180,
		self::PRODUCT_TYPE_DAY365 => 365
	];

	public $type = [
		self::TYPE_MEMBER => '会员充值',
		self::TYPE_GAME => '游戏充值',
	];

	public function setStatisticLog($orno, array $data)
	{
		$key = $this->getStatisticLogKey($orno);
		if (false === S($key))
		{
			S($key, $data);
		}
	}

	public function getStatisticLog($orno)
	{
		return S($this->getStatisticLogKey($orno));
	}

	public function getStatisticLogKey($orno)
	{
		return "sta_orno_" . $orno; 
	}

	public function addToQueue($orno)
	{
		$redis = \Think\Cache::getInstance();
		$redis->rpush($this->getCacheKey(), $orno);
	}

	public function getCacheKey()
	{
		return "order_nos";
	}

	public function setGameLog($orno, array $data)
	{
		$key = $this->getGameLogKey($orno);
		if (false === S($key))
		{
			S($key, $data);
		}
	}

	public function getGameLog($orno)
	{
		return S($this->getGameLogKey($orno));
	}

	public function getGameLogKey($orno)
	{
		return "game_orno_" . $orno; 
	}
}