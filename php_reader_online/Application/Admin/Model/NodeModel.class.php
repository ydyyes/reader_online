<?php
namespace Admin\Model;
use Think\Model;

// 节点模型
class NodeModel extends Model
{
	protected $trueTableName = 'think_node';
	protected $tablePrefix = 'think_';

	protected $_link = array(
		'nodeGroup'	=>	array(
			'mapping_type'	=>	BELONGS_TO,
			'foreign_key'	=>	'group_id',
			'as_fields'		=>	'name:group_name',
		),
	);

	public $_auto		=	array(
		array('action','index'),
		array('status',1),
	);

	protected $_validate	=	array(
		array('name','require','Controler必须填写！'),
		array('title','require','名称必须填写！'),
		array('action','require','action必须填写！'),
	);

	public function checkNode()
	{
		$map['name']   =	 $_POST['name'];
		$map['pid']    =	isset($_POST['pid'])?$_POST['pid']:0;
        $map['status'] = 1;
        if(!empty($_POST['id']))
        {
			$map['id']	=	array('neq',$_POST['id']);
        }
		$result = $this->where($map)->field('id')->find();
        if($result) {
        	return false;
        }else{
			return true;
		}
	}

    public function forbid($options,$field='status')
    {
        if(false === $this->where($options)->setField($field,0))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else {
            return true;
        }
    }

    public function resume($options,$field='status')
    {
        if(false === $this->where($options)->setField($field,1))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else {
            return true;
        }
    }
}