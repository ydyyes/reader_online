<?php
namespace Admin\Controller;

class RoleController extends SystemController
{
	function _filter(&$map)
	{
		isset($_POST['name']) && $map['name'] = array('like',"%".$_POST['name']."%");
	}
	
	function _before_index()
	{
		$NodeName = D("Role")->getField('id, name', true);
		$this->assign("NodeName", $NodeName);
	}

    public function setApp()
    {
        $id       = $_POST['groupAppId'];
		$groupId  =	$_POST['groupId'];
		$group    = D('Role');
		$group->delGroupApp($groupId);
		$result   = $group->setGroupApps($groupId,$id);

		if($result===false) {
			$this->error('项目授权失败！');
		}else {
			$this->success('项目授权成功！');
		}
    }

    public function app()
    {
        //读取系统的项目列表
        $node   =  D("Node");
        $list	=	$node->where('level=1')->field('id,title')->select();
		foreach ($list as $vo){
			$appList[$vo['id']]	=	$vo['title'];
		}

        //读取系统组列表
		$group  =  D('Role');
        $list   =  $group->field('id,name')->select();
		foreach ($list as $vo){
			$groupList[$vo['id']]	=	$vo['name'];
		}
		$this->assign("groupList",$groupList);

        //获取当前用户组项目权限信息
        $groupId =  isset($_GET['groupId'])?$_GET['groupId']:'';
		$groupAppList = array();
		if(!empty($groupId)) {
			$this->assign("selectGroupId",$groupId);
			//获取当前组的操作权限列表
            $list	=	$group->getGroupAppList($groupId);
			foreach ($list as $vo){
				$groupAppList[$vo['id']]	=	$vo['id'];
			}
		}
		$this->assign('groupAppList',$groupAppList);
        $this->assign('appList',$appList);
        $this->display();

        return;
    }

    public function setModule()
    {
        $id     = $_POST['groupModuleId'];
		$groupId	=	$_POST['groupId'];
        $appId	=	$_POST['appId'];
		$group    =   D("Role");
		$group->delGroupModule($groupId,$appId);
		$result = $group->setGroupModules($groupId,$id);

		if($result===false) {
			$this->error('模块授权失败！');
		}else {
			$this->success('模块授权成功！');
		}
    }

    public function module()
    {
        $groupId =  $_GET['groupId'];
        $appId  = $_GET['appId'];

		$group   =  D("Role");
        //读取系统组列表
        $list=$group->field('id,name')->select();
		foreach ($list as $vo){
			$groupList[$vo['id']]	=	$vo['name'];
		}
		$this->assign("groupList",$groupList);

        if(!empty($groupId)) {
			$this->assign("selectGroupId",$groupId);
            //读取系统组的授权项目列表
            $list	=	$group->getGroupAppList($groupId);
			foreach ($list as $vo){
				$appList[$vo['id']]	=	$vo['title'];
			}
            $this->assign("appList",$appList);
        }
        $node    =  D("Node");
        if(!empty($appId)) {
            $this->assign("selectAppId",$appId);
        	//读取当前项目的模块列表
			$where['level']=2;
			$where['pid']=$appId;
            $nodelist=$node->field('id,title')->where($where)->select();
			foreach ($nodelist as $vo){
				$moduleList[$vo['id']]	=	$vo['title'];
			}
        }

        //获取当前项目的授权模块信息
		$groupModuleList = array();
		if(!empty($groupId) && !empty($appId)) {
            $grouplist	=	$group->getGroupModuleList($groupId,$appId);
			foreach ($grouplist as $vo){
				$groupModuleList[$vo['id']]	=	$vo['id'];
			}
		}

		$this->assign('groupModuleList',$groupModuleList);
        $this->assign('moduleList',$moduleList);

        $this->display();

        return;
    }

    public function setAction()
    {
        $id     = $_POST['groupActionId'];
		$groupId	=	$_POST['groupId'];
        $moduleId	=	$_POST['moduleId'];
		$group    =   D("Role");
		$group->delGroupAction($groupId,$moduleId);
		$result = $group->setGroupActions($groupId,$id);

		if($result===false) {
			$this->error('操作授权失败！');
		}else {
			$this->success('操作授权成功！');
		}
    }

    public function action()
    {
        $groupId =  $_GET['groupId'];
        $appId  = $_GET['appId'];
        $moduleId  = $_GET['moduleId'];

		$group   =  D("Role");
        //读取系统组列表
        $grouplist=$group->field('id,name')->select();
		foreach ($grouplist as $vo){
			$groupList[$vo['id']]	=	$vo['name'];
		}
		$this->assign("groupList",$groupList);

        if(!empty($groupId)) {
			$this->assign("selectGroupId",$groupId);
            //读取系统组的授权项目列表
            $list	=	$group->getGroupAppList($groupId);
			foreach ($list as $vo){
				$appList[$vo['id']]	=	$vo['title'];
			}
            $this->assign("appList",$appList);
        }
        if(!empty($appId)) {
            $this->assign("selectAppId",$appId);
        	//读取当前项目的授权模块列表
            $list	=	$group->getGroupModuleList($groupId,$appId);
			foreach ($list as $vo){
				$moduleList[$vo['id']]	=	$vo['title'];
			}
            $this->assign("moduleList",$moduleList);
        }
        $node    =  D("Node");

        if(!empty($moduleId)) {
            $this->assign("selectModuleId",$moduleId);
        	//读取当前项目的操作列表
			$map['level']=3;
			$map['pid']=$moduleId;
            $list	=	$node->where($map)->field('id,title')->select();
			if($list) {
				foreach ($list as $vo){
					$actionList[$vo['id']]	=	$vo['title'];
				}
			}
        }

        //获取当前用户组操作权限信息
		$groupActionList = array();
		if(!empty($groupId) && !empty($moduleId)) {
			//获取当前组的操作权限列表
            $list	=	$group->getGroupActionList($groupId,$moduleId);
			if($list) {
				foreach ($list as $vo){
					$groupActionList[$vo['id']]	=	$vo['id'];
				}
			}
		}

		$this->assign('groupActionList',$groupActionList);
        $this->assign('actionList',$actionList);
        $this->display();
        return;
    }

    public function setUser()
    {
        $id     = $_POST['groupUserId'];
		$groupId	=	$_POST['groupId'];
		$group    =   D("Role");
		$group->delGroupUser($groupId);
		$result = $group->setGroupUsers($groupId, $id);
		if($result===false) {
			$this->error('授权失败！');
		}else {
			$this->success('授权成功！');
		}
    }

    public function user()
    {
        //读取系统的用户列表
        $user    =   D("Admin");
		$list2=$user->field('id,account,nickname')->select();

		foreach ($list2 as $vo){
			$userList[$vo['id']]	=	$vo['account'].' '.$vo['nickname'];
		}

		$group    =   D("Role");
        $list=$group->field('id,name')->select();
		foreach ($list as $vo){
			$groupList[$vo['id']]	=	$vo['name'];
		}
		$this->assign("groupList",$groupList);

        //获取当前用户组信息
        $groupId =  isset($_GET['id'])?$_GET['id']:'';
		$groupUserList = array();
		if(!empty($groupId)) {
			$this->assign("selectGroupId",$groupId);
			//获取当前组的用户列表
            $list	=	$group->getGroupUserList($groupId);
			foreach ($list as $vo){
				$groupUserList[$vo['id']]	=	$vo['id'];
			}

		}
		$this->assign('groupUserList',$groupUserList);
        $this->assign('userList',$userList);
        $this->display();

        return;
    }
    
	public function _before_edit(){
	   $Group = D('Role');
        //查找满足条件的列表数据
        $list     = $Group->field('id,name')->select();
        $this->assign('list',$list);

	}
	
	public function _before_add(){
	   $Group = D('Role');
        //查找满足条件的列表数据
        $list     = $Group->field('id,name')->select();
        $this->assign('list',$list);

	}
	
    public function select()
    {
        $map = $this->_search();
        //创建数据对象
        $Group = D('Role');
        //查找满足条件的列表数据
        $list     = $Group->field('id,name')->select();
        $this->assign('list',$list);
        $this->display();
        return;
    }

    public function grant()
	{
		$model = D( "Role" );
		$id = $_REQUEST [$model->getPk ()];
		$vo = $model->getById ( $id );

		empty($vo) && $this->error("请求的用户组不存在");

		//获取已经存在的权限
		$AccessList = D("Access")->field("node_id")->where(array("role_id"=>$id))->select();
		foreach ($AccessList as $node)
			$Access[$node["node_id"]] = TRUE;

		$grantTable = array();

		/* 取出顶级菜单 */
		$groups = D("NodeGroup")->field(array("id", "name"))->where(array("status"=>1))->select();
		foreach ($groups as $key=>$group)
		{
			/* 取出菜单下的模块 */
			$nodes = D("Node")->field(array("id", "name", "title"))->where(array("level"=>2, "status"=>1, "group_id"=>$group["id"]))
					->order(array("sort"=>"asc"))
					->select();

			/* 取出模块下的方法 */
			foreach ($nodes as $key=>$node)
			{
				$nodes[$key]["action"] = D("Node")->field("id,name,title")
											->where(array("pid"=>$node["id"],"level"=>3,"status"=>1))
											->order("pid asc")
											->select();
			}

			$grantTable[$group["id"]]['group'] = $group;
			$grantTable[$group["id"]]['nodes'] = $nodes;
		}

		//生成一个Hash
		$this->assign("hash", self::hash($id));
		$this->assign("vo", $vo);
		$this->assign("Access", $Access);
		$this->assign('grantTable', $grantTable);
		$this->display();
	}

    public function authorize()
	{
		$model = D( "Role" );
		$id = $_REQUEST [$model->getPk ()];
		$vo = $model->getById ( $id );

		if($vo == FALSE)
			$this->error("请求的用户组不存在");

		//获取已经存在的权限
		$AccessList = D("Access")->field("node_id")->where(array("role_id"=>$id))->select();
		foreach ($AccessList as $node)
			$Access[$node["node_id"]] = TRUE;

		$Node = D("Node");
		$data = $Node->field("id,name,title")->where(array("status"=>1))->order("pid asc")->select();

		$Node = array();
		foreach ($data as $row)
			$Node[$row["id"]] = array('name'=>$row["name"], 'title'=>$row["title"]);

		$order = self::Node();

		//生成一个Hash
		$this->assign("hash", self::hash($id));

		$this->assign("vo", $vo);
		$this->assign("Access", $Access);
		$this->assign("Node", $Node);
		$this->assign("Order", $order);

		$this->display();
	}

	public function Node($pid = 0)
	{
		$node = D("Node");

		$data = $node->field("id,name")->where(array("status"=>1, "pid"=>$pid))->order("sort,id")->select();

		if(!count($data)) return;

		foreach ($data as $key=>$row)
		{
			$array[$row["id"]] = self::Node($row["id"]);
		}

		return $array;
	}

	public function Access()
	{
		if($_POST["hash"] != self::hash($_POST["id"]))
			$this->error("此操作有恶意攻击行为，系统已记录");

		$role_id = I("id", "0", "intval");
		if(empty($role_id) || !D("Role")->find($role_id))
			$this->error("用户角色不存在");

		//删除旧权限
		$Access = D("Access");
		$Access->where(array("role_id"=>$_POST["id"]))->delete();

		//取出合法的权限
		$map['id']  = array('in', $_POST["node_id"]);
		$map['status']  = 1;

		$Node = D("Node");
		$nodelist = $Node->field(array("{$role_id} as role_id", "id as node_id","level","pid"))->where($map)->select();

		foreach ($nodelist as $row)
			$Access->data($row)->add();

		if(C("USER_AUTH_TYPE") == 2)
		{
			$this->success("权限更新成功，并已实时生效");
		}else{
			$this->success("权限更新成功，下次登录时生效");
		}

	}

	protected function hash($id)
	{
		return pwdHash(substr(pwdHash(admin_id(). $id), 1, 10));
	}
}