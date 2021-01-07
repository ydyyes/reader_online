<?php
/**
 * 全局后台公共类，所有后台需要权限控制的模块均需继承于该模块
 * @author shuhai
 */
namespace Admin\Controller;
use Think\Controller;

class SystemController extends Controller
{
	public $_tpl  = null;
	public $model = null;
	public $allow_action = array();
	public $not_allow_action = array();

	function _initialize()
	{

		//只允许指定的操作
		if(!empty($this->allow_action) && !in_array(strtolower(ACTION_NAME), array_map('strtolower',$this->allow_action)))
			return $this->error('不允许执行'.ACTION_NAME.'操作');
		//只允许指定的操作
		if(!empty($this->not_allow_action) && in_array(strtolower(ACTION_NAME), array_map('strtolower',$this->not_allow_action)))
			return $this->error('不允许执行'.ACTION_NAME.'操作');

		// 用户权限检查
		if (C ( 'USER_AUTH_ON' ) && !in_array(MODULE_NAME,explode(',',C('NOT_AUTH_MODULE')))) {
			//此处和IndexAction文件中检验默认项目入口权限一样，可能存在bug
			if (! \Helper\Rbac::AccessDecision (APP_NAME)) {
				//检查认证识别号
				if (! $_SESSION [C ( 'USER_AUTH_KEY' )]) {
					//如果处于登陆状态，则弹出301超时提示
					if(IS_AJAX)
					{
						$this->ajaxReturn(array("info"=>"登陆超时，请重新登陆", "status"=>501));
						exit;
					}

					//跳转到认证网关
					redirect ( PHP_FILE . C ( 'USER_AUTH_GATEWAY' ) );
				}
				// 没有权限 抛出错误
				if (C ( 'RBAC_ERROR_PAGE' )) {
					// 定义权限错误页面
					redirect ( C ( 'RBAC_ERROR_PAGE' ) );
				} else {
					if (C ( 'GUEST_AUTH_ON' )) {
						$this->assign ( 'jumpUrl', PHP_FILE . C ( 'USER_AUTH_GATEWAY' ) );
					}
					
					if(APP_DEBUG)
						exit('RBAC权限不够');

					// 提示错误信息
					$this->assign('jumpUrl', U("Public/logout"));
					$this->assign('waitSecond', 5);
					$this->error (L ( '_VALID_ACCESS_' ) . "，请联系管理员授权!<br />当前操作：".MODULE_NAME . " -> " . ACTION_NAME);
				}
			}
		}

		//共用前置操作
		if(method_exists($this, "_before"))
			call_user_func(array($this, "_before"));

        if (isset($_REQUEST["_search"]))
        {
            $this->assign ('_search', $_REQUEST['_search']);
        }
		$this->assign("waitSecond", 60);
	}

	public function ajaxAssign(&$result)
	{
		$result['statusCode']  =  $result['status'];
		$result['navTabId']  =  $_REQUEST['navTabId'];
		$result['callbackType']  =  $_REQUEST['callbackType'];
		$result['message'] =  $result['info'];
	}

	public function index($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		//列表过滤器，生成查询Map对象
		$map = $this->_search ($this->model);

		if (method_exists ( $this, '_filter' )) {
			$this->_filter ( $map );
		}

		$model = D ($this->model);
		if (! empty ( $model )) {
			$this->_list ( $model, $map );
		}

		$this->assign ('map', $map);
		$this->display ();
		return;
	}

	/**
	 * 取得操作成功后要返回的URL地址
	 * 默认返回当前模块的默认操作
	 * 可以在action控制器中重载
	 * @access public
	 * @return string
	 * @throws ThinkExecption
	 */
	function getReturnUrl()
	{
		return __URL__ . '?' . C ( 'VAR_MODULE' ) . '=' . MODULE_NAME . '&' . C ( 'VAR_ACTION' ) . '=' . C ( 'DEFAULT_ACTION' );
	}

	/**
	 * 根据表单生成查询条件
	 * 进行列表过滤
	 * @access protected
	 * @param string $name 数据对象名称
	 * @return HashMap
	 * @throws ThinkExecption
	 */
	protected function _search($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();

		$model = D ( $modelName );
		$map = array ();
		foreach ( $model->getDbFields () as $key => $val ) {
			if (isset ( $_REQUEST [$val] ) && $_REQUEST [$val] != '')
				$map [$val] = $_REQUEST [$val];
		}

		return $map;
	}
	
	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
	}

	/**
	 * 根据表单生成查询条件
	 * 进行列表过滤
	 * @access protected
	 * @param Model $model 数据对象
	 * @param HashMap $map 过滤条件
	 * @param string $sortBy 排序
	 * @param boolean $asc 是否正序
	 * @return void
	 * @throws ThinkExecption
	 */
	protected function _list($model, $map, $sortBy='', $asc=false)
	{

		if (!$order = I("orderField", "", "trim")) {
			$pk    = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
			$order = ! empty( $sortBy) ? $sortBy : $pk;
			$order = is_array($order) ? join(", ", $order) : $order;
			$_REQUEST['orderField'] = $order;
		}

		//排序方式默认按照倒序排列
		//接受 sost参数 0 表示倒序 非0都 表示正序
		if (isset($_REQUEST['orderDirection'])) {
			$sort = (strtolower($_REQUEST ['orderDirection']) == 'asc') ? 'asc' : 'desc';
		} else {
			$sort = $asc ? 'asc' : 'desc';
			$_REQUEST['orderDirection'] = $sort;
		}

		$_GET[C('VAR_PAGE')] = !empty($_REQUEST[C('VAR_PAGE')])?$_REQUEST[C('VAR_PAGE')]:1;

		//取得满足条件的记录数
		$count = $model->where($map)->count('*');
		\Think\Log::write($model->_sql, \Think\Log::DEBUG);

		if ($count > 0) {
			//创建分页对象
			if(!empty( $_REQUEST['numPerPage'] )) {
				$listRows = intval($_REQUEST ['numPerPage']) ? intval($_REQUEST ['numPerPage']) : C('PAGE_LISTROWS');
				cookie("numPerPage", intval($_REQUEST ['numPerPage']));
			}
			if(cookie("numPerPage") > 0) {
				$listRows = cookie("numPerPage");
				cookie("numPerPage", $listRows);
			}


			$listRows = empty($listRows) ? C('PAGE_LISTROWS') : $listRows;

			$p = new \Think\Page( $count, $listRows );

			$voList = $model->where($map)->order($order . " " . $sort)->limit($p->firstRow, $p->listRows)->select();
			//当页面只需要返回数据
			if(method_exists($this, '_after_select'))
				call_user_func_array(array($this, '_after_select'), array(&$voList));
			
			//分页跳转的时候保证查询条件
			foreach ( $map as $key => $val ) {
				if (! is_array ( $val ))
					$p->parameter .= "$key=" . urlencode ( $val ) . "&";
			}

			//分页显示
			$page = $p->show ();

			//列表排序显示
			$sortImg = $sort; //排序图标
			$sortAlt = $sort == 'desc' ? '升序排列' : '倒序排列'; //排序提示
			$sort = $sort == 'desc' ? 1 : 0; //排序方式

			//模板赋值显示
			$this->assign ( 'list', $voList );
			$this->assign ( 'sort', $sort );
			$this->assign ( 'order', $order );
			$this->assign ( 'sortImg', $sortImg );
			$this->assign ( 'sortType', $sortAlt );
			$this->assign ( "page", $page );
		}
		$this->assign ( 'totalCount', $count );
		$this->assign ( 'numPerPage', $listRows );
		$this->assign ( 'currentPage', !empty($_REQUEST[C('VAR_PAGE')]) ? $_REQUEST[C('VAR_PAGE')] : 1);

		cookie ( '_currentUrl_', __SELF__ );
		return;
	}

	function insert($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();

		$model = D ($modelName);
		
		if (false === $model->create ()) {
			$this->error ( $model->getError () );
		}

		//保存当前数据对象
		$list=$model->add();
		if ($list!==false)
		{
			if(method_exists($this, '_after_insert'))
				call_user_func_array(array($this, '_after_insert'), array($model));

			$this->assign ( 'jumpUrl', cookie ( '_currentUrl_' ) );
			$this->success ('新增成功!', 'closeCurrent');
		} else {
			$this->log_error($model->getDbError());
			$this->error ('新增失败!');
		}
	}

	public function add()
	{
		$this->display ();
	}

	function read()
	{
		$this->edit ();
	}

	function edit($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		$pk    = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
		$id    = $_REQUEST[$pk];
		$id    = intval($id);

		if(empty($id) ||!$vo = $model->where(array($pk=>$id))->find())
			$this->error ('您要修改的记录不存在');

		$this->assign ('vo', $vo);
		$this->display ();
	}

	function update($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		$pk    = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
		$map = array($pk=>$_POST[$pk]);
		$data = $model->create($_POST);
		if (false === $data) {
			$this->error ( $model->getError () );
		}
		//默认只更新一条记录
		$result = $model->where($map)->limit(1)->save($data);

		if (false !== $result) {
			if(method_exists($this, '_after_update'))
				call_user_func_array(array($this, '_after_update'), array($model));

			//成功提示
			$this->assign ( 'jumpUrl', cookie ( '_currentUrl_' ) );
			$this->success ('编辑成功!', 'closeCurrent');
		} else {
			$this->log_error($model->getDbError());
			$this->error ('编辑失败!');
		}
	}

	/**
	 * 软删除
	 */
	public function delete($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		if (! empty ( $model )) {
			$pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
			$id = $_REQUEST [$pk];
			if (isset ( $id )) {
				$condition = array ($pk => array ('in', explode ( ',', $id ) ) );
				$data = array('is_delete'=>1, 'delete_at'=>time());
				$list = $model->where ( $condition )->save($data);
				if ($list!==false) {
					$this->success ('删除成功！' );
				} else {
					$this->log_error($model->getDbError());
					$this->error ('删除失败！');
				}
			} else {
				$this->error ( '非法操作' );
			}
		}
	}
	
	/**
	 * 物理删除
	 */
	public function foreverdelete($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		if (! empty ( $model )) {
			$pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
			$id = $_REQUEST [$pk];
			if (isset ( $id )) {
				$condition = array ($pk => array ('in', explode ( ',', $id ) ) );
				if (false !== $model->where ( $condition )->delete ()) {
					$this->success ('删除成功！');
				} else {
					$this->log_error($model->getDbError());
					$this->error ('删除失败！');
				}
			} else {
				$this->error ( '非法操作' );
			}
		}
		$this->forward ();
	}

	public function forbid($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		$pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
		$id = $_REQUEST [$pk];
		$condition = array ($pk => array ('in', $id ) );
		$list=$model->forbid ( $condition );
		if ($list!==false) {
			$this->assign ( "jumpUrl", $this->getReturnUrl () );
			$this->success ( '状态禁用成功' );
		} else {
			$this->error  (  '状态禁用失败！' );
		}
	}

	public function recycle($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		$pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
		$id = $_REQUEST [$pk];
		$condition = array ($pk => array ('in', $id ) );
		if (false !== $model->recycle ( $condition )) {

			$this->assign ( "jumpUrl", $this->getReturnUrl () );
			$this->success ( '状态还原成功！' );

		} else {
			$this->error   (  '状态还原失败！' );
		}
	}

	public function recycleBin($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		
		$map = $this->_search ();
		$map ['status'] = - 1;
		if (! empty ( $model )) {
			$this->_list ( $model, $map );
		}
		$this->display ();
	}

	/**
	 * 默认恢复操作
	 *
	 * @access public
	 * @return string
	 * @throws FcsException
	 */
	function resume($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);
		$pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
		$id = $_REQUEST[$pk];
		$condition = array ($pk => array ('in', $id ) );
		if (false !== $model->resume ( $condition )) {
			$this->assign ( "jumpUrl", $this->getReturnUrl () );
			$this->success ( '状态恢复成功！' );
		} else {
			$this->error ( '状态恢复失败！' );
		}
	}

    /**
     * 节点AJAX排序操作，Add BY 4wei.cn
     * @access public
     * @return void
     */
    public function sort($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);

		$model->create($_GET);
        $model->save();
        $this->success ('操作成功');
    }

    /**
     * 多字段重复数据检查
     * @access public
     * @return void
     */
    public function exist($where, $model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		$model = D ($modelName);

		$result = $model->where($where)->find();
        return is_array($result) ? $result : FALSE;
    }

	//兼容DWZ框架的页面提示
    protected function ajaxReturn($data,$type='',$json_option=0)
    {
    	$data["statusCode"] = $data["status"];
    	$data['message'] = $data['info'];
    	
    	unset($data["status"]);
    	unset($data['info']);
    	
    	if($callbackType = I('request.callbackType'))
    		$data["callbackType"] = $callbackType;
    	if($navTabId = I('request.navTabId'))
    		$data["navTabId"] = $navTabId;
    	
    	parent::ajaxReturn($data, $type, JSON_UNESCAPED_UNICODE);
    }

    protected function success($message='',$jumpUrl='',$ajax=false)
    {
    	if($jumpUrl == 'closeCurrent')
    		$_GET['callbackType'] = 'closeCurrent';
    	parent::success($message,$jumpUrl='',$ajax=false);
    	exit;
    }

    protected function error($message='',$jumpUrl='',$ajax=false)
    {
    	parent::error($message,$jumpUrl='',$ajax=false);
    	exit;
    }

    protected function log_error($error)
    {
    	\Think\Log::write('SQL EXECUTE EMERG ERROR: ' . $error, \Think\Log::EMERG);
    	APP_DEBUG && E($error);
    }

    function display($templateFile='',$charset='',$contentType='',$content='',$prefix='')
    {
    	if($templateFile=='' && isset($this->_tpl))
    		$templateFile = $this->_tpl;

    	parent::display($templateFile,$charset,$contentType,$content,$prefix);
    }

    function getActionName()
    {
    	return CONTROLLER_NAME;
    }
}