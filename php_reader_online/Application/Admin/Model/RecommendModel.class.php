<?php
namespace Admin\Model;

/**
 * Class RecommendModel
 * @package Admin\Model
 */
class RecommendModel extends SystemModel
{
	protected $trueTableName = 'xs_recommend';

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
}