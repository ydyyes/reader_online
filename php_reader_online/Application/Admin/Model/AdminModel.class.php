<?php
namespace Admin\Model;
use Think\Model;

// 管理员模型
class AdminModel extends Model
{
	protected $trueTableName = 'think_admin';
	protected $readonlyField = array('account') ;

	public $_validate	=	array(
		array('account','/^[a-z]\w{3,}$/i','帐号格式错误'),
		array('password','require','密码必须填写'),
		array('nickname','require','昵称必须填写'),
		array('email','email','邮箱地址必须填写'),
		array('repassword','require','确认密码必须'),
		array('repassword','password','确认密码不一致',self::EXISTS_VALIDATE,'confirm'),
		array('account','','帐号已经存在',self::EXISTS_VALIDATE,'unique',self::MODEL_INSERT),
	);

	public $_auto		=	array(
		array('password','pwdHash',self::MODEL_BOTH,'callback'),
		array('create_time','time',self::MODEL_INSERT,'function'),
		array('update_time','time',self::MODEL_UPDATE,'function'),
	);

	protected function pwdHash()
	{
		if(isset($_POST['password']))
		{
			return pwdHash($_POST['password']);
		}else{
			return false;
		}
	}

    public function forbid($options,$field='status')
    {
        if(false === $this->where($options)->setField($field,0)){
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else{
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
            return True;
        }
    }

    function getNickname($map)
    {
    	if(is_numeric($map))
    		$map = array("id" => $map);
    	$name = $this->where($map)->getField("account, nickname");
    	if(empty($name['account']))
    		return key($name);
    	return $name['account'];
    }
}