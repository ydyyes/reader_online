<?php
namespace Admin\Controller;
use Think\Controller;

class PublicController extends Controller
{
	public function ajaxAssign(&$result)
	{
		$result['statusCode']  =  $result['status'] == 1 ? 200 : $result['status'];
		$result['navTabId']  =  $_REQUEST['navTabId'];
		$result['callbackType']  =  $_REQUEST['callbackType'];
		$result['message'] =  $result['info'];
	}

    // 后台首页 查看系统信息
    public function main()
    {
    	!defined('SYS_VERSION') && include APP_PATH.'/version.php';
        $info = array(
        	'系统版本'				=>SYS_VERSION,
			'最后更新'				=>SYS_RELEASE,
            '操作系统'				=>PHP_OS,
            '运行环'					=>$_SERVER["SERVER_SOFTWARE"],
            'PHP运行方式'			=>php_sapi_name(),
            'ThinkPHP'			=>THINK_VERSION,
            '上传附件限制'			=>ini_get('upload_max_filesize'),
            '执行时间限制'			=>ini_get('max_execution_time').'秒',
            '服务器时间'				=>date("Y年n月j日 H:i:s"),
            '北京时间'				=>gmdate("Y年n月j日 H:i:s",time()+8*3600),
            '服务器'			=>$_SERVER['SERVER_NAME'].' [ '.gethostbyname($_SERVER['SERVER_NAME']).' ]',
            '剩余空间'				=>round((@disk_free_space(".")/(1024*1024*1024)),2).'G',
        );
        $this->assign('info',$info);
        $this->display();
    }

	// 用户登录页面
	public function login()
	{
		if(!isset($_SESSION[C('USER_AUTH_KEY')])) {
			$this->display();
		}else{
			$this->redirect('Index/index');
		}
	}

	public function index()
	{
		//如果通过认证跳转到首页
		redirect(__APP__);
	}

	// 用户登出
    public function logout()
    {
        if(isset($_SESSION[C('USER_AUTH_KEY')])) {
			unset($_SESSION[C('USER_AUTH_KEY')]);
			unset($_SESSION);
			session_destroy();

            $this->redirect('Index/index');
        }else {
            $this->error('已经登出！', 'Index/index');
        }
    }
	
	// 登录检测
	public function checkLogin()
	{
    	$verify = new \Think\Verify();
    	if(!$verify->check($_POST['verify'], 99))
			return $this->error('验证码错误！');

		$this->change_verify();
		if(empty($_POST['account']) || empty($_POST['password']))
			return $this->error('请正确填写您的登录帐号！');

        //生成认证条件
        $map            =   array();
		// 支持使用绑定帐号登录
		$map['account']	= $_POST['account'];
        $map["status"]	=	array('gt',0);

        $authInfo = \Helper\Rbac::authenticate($map);
        //使用用户名、密码和状态的方式进行认证
        if(false === $authInfo) {
            return $this->error('帐号不存在或已禁用！');
        }else {
            if($authInfo['password'] != md5($_POST['password']))
            	return $this->error('密码错误！');

            $_SESSION[C('USER_AUTH_KEY')]	=	$authInfo['id'];
            $_SESSION['email']              =	$authInfo['email'];
            $_SESSION['loginUserName']		=	$authInfo['nickname'];
            $_SESSION['lastLoginTime']		=	$authInfo['last_login_time'];
			$_SESSION['login_count']	    =	$authInfo['login_count'];
            if($authInfo['account']=='admin')
            	$_SESSION['administrator']		=	true;

            //保存登录信息
			$User	=	D("Admin");
			$ip		=	get_client_ip();
			$time	=	time();
            $data = array();
			$data['id']	=	$authInfo['id'];
			$data['last_login_time']	=	$time;
			$data['login_count']	=	array('exp','login_count+1');
			$data['last_login_ip']	=	$ip;
			$User->save($data);

			// 缓存访问权限
            \Helper\Rbac::saveAccessList();

            //记住登陆用户名
            Cookie('last_login', $authInfo['account']);

			//如果处于登陆状态，则弹出301超时提示
			if(IS_AJAX)
				echo json_encode(array("message"=>"登陆成功", "statusCode"=>1, "callbackType"=>'closeCurrent'));
			else
				$this->display("loginSuccess");
		}
	}
    // 更换密码
    public function changePwd()
    {
    	$verify = new \Think\Verify();
    	if(!$verify->check($_POST['verify'], 99))
			return $this->error('验证码错误！');

		$map	=	array();
        $map['password']= pwdHash($_POST['oldpassword']);
        if(isset($_POST['account'])) {
            $map['account']	 =	 $_POST['account'];
        }elseif(isset($_SESSION[C('USER_AUTH_KEY')])) {
            $map['id']		=	$_SESSION[C('USER_AUTH_KEY')];
        }
        //检查用户
        $User    =   D("Admin");
        if(!$User->where($map)->field('id')->find()) {
            return $this->error('旧密码不符或者用户名错误！');
        }else {
			$User->password	=	pwdHash($_POST['password']);
			$User->text		=	codeStr($_POST['password']);
			$User->save();
			$this->success('密码修改成功！');
         }
    }

	public function profile() {
		$User	 =	 D("Admin");
		$vo	=	$User->getById($_SESSION[C('USER_AUTH_KEY')]);
		$this->assign('vo',$vo);
		$this->display();
	}

	public function verify()
    {
    	$config = array("fontSize"=>10, "useCurve"=>false, "useNoise"=>false, "length"=>4, "imageW"=>65, "imageH"=>25, "codeSet"=>'023456789', 'fontttf'=>'4.ttf');
		$Verify = new \Think\Verify($config);
		$Verify->entry(99);
    }

	public function change_verify()
    {
    	$verify = new \Think\Verify();
    	$verify->check($_POST['verify'], 99);
    }

	public function change() {
		$User	 =	 D("Admin");
		if(!$User->create())
			return $this->error($User->getError());

		$result	=	$User->save();
		if(false !== $result) {
			$this->success('资料修改成功！');
		}else{
			$this->error('资料修改失败!');
		}
	}

    function isAjax()
    {
        return IS_AJAX;
    }
}