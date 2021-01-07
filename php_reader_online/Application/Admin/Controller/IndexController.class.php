<?php
namespace Admin\Controller;

class IndexController extends SystemController
{
	public function index()
	{
		/* 根据用户权限显示左侧菜单 */
		if(empty($_SESSION[C('USER_AUTH_KEY')]) && empty($_SESSION['administrator']))
			return $this->error('您没有任何可操作权限');

		$group = D("NodeGroup");
		$node_group = $group->where("status >0 and id > 1")->field(array('id','name',))->order("sort")->select();

		$data = array();

        foreach ($node_group as $group)
        {
            //显示菜单项
            $menu  = array();

        	//读取数据库模块列表生成菜单项
			$node    =   D("Node");
			$id	=	$node->getField("id");
			$where['level']=2;
			$where['type']=0;
			$where['status']=1;
			$where['pid']=$id;
			$where['group_id']=$group['id'];
			$list	=	$node->where($where)->field('id,name,action,params,group_id,title')->order('sort asc')->select();

			$accessList = \Helper\Rbac::getAccessList($_SESSION[C('USER_AUTH_KEY')]);
			foreach($list as $key=>$module) {
				//此处可能存在bug隐患
				if(isset($accessList[strtoupper(APP_NAME)][strtoupper($module['name'])]) || $_SESSION['administrator'])
				{
					$params = empty($module['params']) ? array() : $this->params($module['params']);
					$module['url'] = U("{$module['name']}/{$module['action']}/", $params);

					//设置模块访问权限
					$module['access'] =   1;
					$menu[$key]  = $module;
			    }
			}

            !empty($menu) && $data[$group['id']] = array('name'=>$group['name'], 'menu'=>$menu);
		}

		if(!empty($_GET['tag'])){
			$this->assign('menu',$_GET['tag']);
		}

		//调用统计信息
		//$this->stat();

		$userDetail = D("Admin")->where(array("id"=>admin_id()))->find();
		$this->assign('userDetail', $userDetail);
		$this->assign('menu', $data);
		$this->display();
	}

	/* 格式化参数 */
	protected function params($params)
	{
		if (empty($params)) return array();

		$array = explode("\n", $params);
		foreach ($array as $value)
		{
			if(empty($value)) continue;
			list($k, $v) = explode("=", $value);
			$param[$k] = $v;
		}

		return $param;
	}
}