<?php
namespace Admin\Model;

/**
 * Class CoinLogModel
 * @package Admin\Model
 */
class CoinLogModel extends SystemModel
{
	protected $trueTableName = 'xs_coin_log';

	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
	    array('update_at','time',self::MODEL_INSERT,'function'),
	    array('update_at','time',self::MODEL_UPDATE,'function'),
	);

	const TYPE_PAY = 1;
	const TYPE_WITHDRAW = 2;

	const STATUS_SUCC = 1;   //充值成功，或提现成功
	const STATUS_APPEND = 0;  //提现审核
	const STATUS_APPEND_FAILD = 2;//提现失败

	public $status = [
		self::STATUS_SUCC => '成功',
		self::STATUS_APPEND => '审核中',
		self::STATUS_APPEND_FAILD => '失败',
	];

	public $type = [
		self::TYPE_PAY => '充值',
		self::TYPE_WITHDRAW => '提现',
	];

}