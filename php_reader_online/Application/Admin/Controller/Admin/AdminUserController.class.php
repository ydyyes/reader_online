<?php
/**
 * 控制器分级测试文件
 * @author shuhai
 */

namespace Admin\Controller\Admin;
use Admin\Controller\SystemController;

// 后台用户模块
class AdminUserController extends SystemController
{
    public $model = "admin";

	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
		$map['id'] = array('egt',2);
	}

	public function _before_update()
	{
		//管理员用户名禁止修改
		unset($_POST["account"]);
	}

	// 检查帐号
	public function checkAccount()
	{
        if(!preg_match('/^[a-z]\w{4,}$/i',$_POST['account'])) {
            $this->error( '用户名必须是字母，且5位以上！');
        }
		$User = D("Admin");
        // 检测用户名是否冲突
        $name    =  I("request.account");
        $result  =  $User->getByAccount($name);
        if($result) {
        	$this->error('该用户名已经存在！');
        }else {
           	$this->success('该用户名可以使用！');
        }
    }

	protected function addRole($userId)
	{
		//新增用户自动加入相应权限组
		$RoleUser = D("RoleUser");
		$RoleUser->user_id = $userId;
		$RoleUser->add();
	}

    //重置密码
    public function resetPwd()
    {
    	if($_POST['password'] != $_POST['repassword'])
    		$this->error('密码确认不一致，请认真检查！');

    	$id  =  $_POST['id'];
        $password = $_POST['password'];
        if(''== trim($password)) {
        	$this->error('密码不能为空！');
        }

        if(empty($id) || !D("Admin")->find($id))
        	$this->error('用户不存在');

        $User = D("Admin");
		$User->password	= md5($password);
		$User->id       = $id;
		$result         = $User->save();
        if(false !== $result) {
            $this->success("密码修改成功");
        }else {
        	$this->error('重置密码失败，请联系管理员！');
        }
    }

    public function assper()
    {
        $id = I('get.id', "intval", 0);
        if (! $id)
        {
            $this->error('无效的连接');
        }
    
        $channelMod = D('SysChannel');
         
        $channelConfig = array(
//            1 => array(
//                'detail' => 'CP管理组:',
//                'name' => 'cp',
//            ),
            2 => array(
                'detail' => '渠道管理组:',
                'name' => 'channel',
            ),
//             3 => array(
//                 'detail' => 'SDK管理组:',
//                 'name' => 'sdk',
//             ),
        );
        $info = $channelMod->where(array('status' => 1))->select();
        if ($info)
        {
            foreach ($info as $val)
            {
                $channelConfig[$val['type']]['data'][] = array(
                    'id' => $val['id'],
                    'name' => $val['cname'],
                );
            }
        }
        
         
        $channelGroup = array();
         
        $channelMod = D("SysChannelPower");
        $tmp = $channelMod->where(array('admin_id' => $id))->find();
        if (isset($tmp['memo']))
        {
            $tmp['memo'] = json_decode($tmp['memo'], true);
            $qdInfo = isset($tmp['memo']['qd']) && ! empty($tmp['memo']['qd']) ? explode(',', $tmp['memo']['qd']) : array();
            $cpInfo = isset($tmp['memo']['cp']) && ! empty($tmp['memo']['cp']) ? explode(',', $tmp['memo']['cp']) : array();
            $sdkInfo = isset($tmp['memo']['sdk']) && ! empty($tmp['memo']['sdk']) ? explode(',', $tmp['memo']['sdk']) : array();
    
            $channelGroup = array_merge($qdInfo, $cpInfo, $sdkInfo);
    
            $this->assign('qdInfo', $qdInfo ? implode(',', $qdInfo) : '');
            $this->assign('cpInfo', $cpInfo ? implode(',', $cpInfo) : '');
            $this->assign('sdkInfo', $sdkInfo ? implode(',', $sdkInfo) : '');
    
        }
         
        $showConfig = array(1, 2);//1：显示，2：不显示
         
        //是否显示cp组在数据统计页面
        $cpStatus = isset($tmp['cp_is_show']) && in_array($tmp['cp_is_show'], $showConfig) ? (int) $tmp['cp_is_show'] : 2;
        //是否显示渠道组在数据统计页面
        $channelStatus = isset($tmp['channel_is_show']) && in_array($tmp['channel_is_show'], $showConfig) ? (int) $tmp['channel_is_show'] : 2;
         
        //是否显示sdk组在数据统计页面
        $sdkStatus = isset($tmp['sdkIsShow']) && in_array($tmp['sdkIsShow'], $showConfig)? (int) $tmp['sdkIsShow'] : 2;
         
        $this->assign('cpStatus', $cpStatus);
        $this->assign('channelStatus', $channelStatus);
        $this->assign('id', $id);
        $this->assign('channelGroup', $channelGroup);
        $this->assign('channelConfig', $channelConfig);
        $this->display();
    }
    
    public function assperSave()
    {
        $id = I('post.id', "intval", 0);
        if (! $id)
        {
            $this->error('无效的连接');
        }
         
        //是否显示CP组在数据统计页面
        $cpStatus = I('post.cpStatus', 2, 'intval');
         
        //是否显示渠道组在数据统计页面
        $channelStatus = I('post.channelStatus', 2, 'intval');
         
         
        //渠道
        $cid = I('post.s_channel', '', 'htmlspecialchars');
        $cid = ! empty($cid) ? explode(',', $cid) : '';
    
        //CP
        $pid = I('post.s_cp', '', 'htmlspecialchars');
        $pid = ! empty($pid) ? explode(',', $pid) : '';
    
        $memo = array(
            'qd' => $cid ? implode(',', $cid) : array(),
            'cp' => $pid ? implode(',', $pid) : array(),
        );
    
        $channelMod = D("SysChannelPower");
        $info = $channelMod->where(array('admin_id' => $id))->find();
        //更新
        if ($info)
        {
            $field['memo'] = json_encode($memo);
            $field['cp_is_show'] = $cpStatus;
            $field['channel_is_show'] = $channelStatus;
            $field['updateby'] = admin_id();
            $field['update_time'] = time();
            $real = $channelMod->where(array('admin_id' => $id))->save($field);
        }
        //添加
        else
        {
            $field['cp_is_show'] = $cpStatus;
            $field['channel_is_show'] = $channelStatus;
            $field['sdkIsShow'] = $sdkStatus;
            $field['admin_id'] = $id;
            $field['memo'] = json_encode($memo);
            $field['createby'] = admin_id();
            $field['create_time'] = time();
            $real = $channelMod->add($field);
        }
    
        if($real !== false)
        {
            $this->success("授权成功");
        }
        else
        {
            $this->error("系统错误，授权失败");
        }
    }
    
}