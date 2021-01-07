<?php
namespace Admin\Model;
use Think\Model;

class SystemModel extends Model
{
    function _initialize()
    {
        if(MODULE_NAME == 'Admin')
        {
            $this->db_instance();
            $this->_checkTableInfo();
        }
    }
    
	// 获取当前用户的ID
    public function getMemberId()
    {
        return session(C('USER_AUTH_KEY'));
    }

   /**
     * 根据条件禁用表数据
     * @access public
     * @param array $options 条件
     * @return boolen
     */
    public function forbid($options,$field='status')
    {
        if(FALSE === $this->where($options)->setField($field,0))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else{
            return True;
        }
    }

    /**
     * 根据条件恢复表数据
     * @access public
     * @param array $options 条件
     * @return boolen
     */
    public function resume($options,$field='status')
    {
        if(FALSE === $this->where($options)->setField($field,1))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else {
            return True;
        }
    }

    /**
     * 根据条件恢复表数据
     * @access public
     * @param array $options 条件
     * @return boolen
     */
    public function recycle($options,$field='status')
    {
        if(FALSE === $this->where($options)->setField($field,0))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else{
            return True;
        }
    }

    public function recommend($options,$field='is_recommend')
    {
        if(FALSE === $this->where($options)->setField($field,1))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else{
            return True;
        }
    }

    public function unrecommend($options,$field='is_recommend')
    {
        if(FALSE === $this->where($options)->setField($field,0))
        {
            $this->error =  L('_OPERATION_WRONG_');
            return false;
        }else{
            return True;
        }
    }

    public function getUpBySonId($sonId)
    {
    	$son = $this->cache(true)->find($sonId);
    	if(empty($son['upid']))
    		return (object)$son;
    	
    	$top = $this->cache(true)->find($son['upid']);

    	return (object)$top;
    }

    public function datetime($time="")
    {
    	if(empty($time)) $time = time();
    	return date("Y-m-d H:i:s", $time);
    }

    public function getStatus($sid)
    {
    	return $this->status[$sid];
    }
    
    public function getPk()
    {
    	return isset($this->_pk) ? $this->_pk : parent::getPk();
    }
}