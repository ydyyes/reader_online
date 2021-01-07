<?php
namespace Admin\Model;

/**
 * Class GamesModel
 * @package Admin\Model
 */
class GamesModel extends SystemModel
{
	protected $trueTableName = 'xs_games';

	protected $_validate = array(
        array('name','require','name不能为空！')
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
}