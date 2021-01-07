<?php
namespace Admin\Model;

/**
 * Class WithdrawLogModel
 * @package Admin\Model
 */
class WithdrawLogModel extends SystemModel
{
	protected $trueTableName = 'xs_withdraw_log';

	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
	    array('update_at','time',self::MODEL_INSERT,'function'),
	    array('update_at','time',self::MODEL_UPDATE,'function'),
	);

	const STATUS_SUCC = 1;
	const STATUS_APPEND = 0;
	const STATUS_APPEND_FAILD = 2;

	public $status = [
		self::STATUS_SUCC => '成功',
		self::STATUS_APPEND => '审核中',
		self::STATUS_APPEND_FAILD => '失败',
	];

	public $radio = 0.02;
}