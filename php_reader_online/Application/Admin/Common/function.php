<?php
function getStatus($status, $imageShow=false) {
	switch ($status) {
		case 0 :
			$showText = '已禁用';
			$showImg = '<img src="' . cdn("Public") . '/app/dwz/Images/locked.gif" width="20" height="20" border="0" title="已禁用" alt="已禁用">';
			break;
		case - 1 :
			$showText = '已删除';
			$showImg = '<img src="' . cdn("Public") . '/app/dwz/Images/del.gif" width="20" height="20" border="0" title="已删除" alt="已删除">';
			break;
		default :
			$showText = '正常';
			$showImg = '<img src="' . cdn("Public") . '/app/dwz/Images/ok.gif" width="20" height="20" border="0" alt="正常">';

	}
	return ($imageShow === true) ?  $showImg  : $showText;
}

function showStatus($status, $id, $callback="") {
	switch ($status) {
		//当数据被禁用
		case 0 :
			$info = '<a href="__URL__/resume/id/' . $id . '/navTabId/__MODULE__" target="ajaxTodo" callback="'.$callback.'">启用</a>';
			break;
		case 2 :
			$info = '<a href="__URL__/pass/id/' . $id . '/navTabId/__MODULE__" target="ajaxTodo" callback="'.$callback.'">批准</a>';
			break;
		//正常
		case 1 :
			$info = '<a href="__URL__/forbid/id/' . $id . '/navTabId/__MODULE__" target="ajaxTodo" callback="'.$callback.'">禁用</a>';
			break;
		//当数据被删除
		case - 1 :
			$info = '<a href="__URL__/recycle/id/' . $id . '/navTabId/__MODULE__" target="ajaxTodo" callback="'.$callback.'">还原</a>';
			break;
	}
	return str_replace(array("__URL__", "__MODULE__"), array(__CONTROLLER__, strtoupper(CONTROLLER_NAME)), $info);
}

function reviewStatus($status, $id, $callback="") {
    $succ = '<a href="__URL__/review_succ/id/' . $id . '/navTabId/__MODULE__" target="ajaxTodo" callback="'.$callback.'">通过</a>';
    $faild = '<a href="__URL__/review_faild/id/' . $id . '/navTabId/__MODULE__" target="ajaxTodo" callback="'.$callback.'">拒绝</a>';
    switch ($status) {
        //审核失败
        case 0 :
            $info = $succ;
            break;
        //审核通过
        case 1 :
            $info = $faild;
            break;
        //审核ing
        case -1:
            $info = $succ . " " . $faild;
            break;
    }
    return str_replace(array("__URL__", "__MODULE__"), array(__CONTROLLER__, strtoupper(CONTROLLER_NAME)), $info);
}

function pwdHash($password, $type = 'md5') {
	return hash ( $type, $password );
}

// 存储特殊内容的加密函数
function codeStr($string, $action = 'ENCODE', $hash = '')
{
	$action != 'ENCODE' && $string = base64_decode($string);
    $code = '';
    ! $hash && $hash = 'luge';
    $key = md5($hash.'_kingsgame');
    $keylen = strlen($key);
    $strlen = strlen($string);
    for ($i = 0; $i < $strlen; $i ++) {
        $k = $i % $keylen; //余数  将字符全部位移
        $code .= $string[$i] ^ $key[$k];//位移
    }
    return ($action != 'DECODE' ? base64_encode($code) : $code);
}

//获取当前登陆的管理员id
function admin_id()
{
	return session(C('USER_AUTH_KEY')) ? session(C('USER_AUTH_KEY')) : 0;
}

//获取当前登陆管理员的渠道
function admin_channel_id()
{
	$admin_id = admin_id();
	if(empty($admin_id))
		return 0;

	$map = array("id"=>$admin_id);
	$channel_id = D("Admin")->where( $map )->cache(false)->getField("agent_id");
	return !empty($channel_id) ? $channel_id : 1;
}

//获取当前登陆的管理员 account
function admin_account($field='account')
{
	$map['id'] = session(C('ADMIN_AUTH_KEY'));
	return D("Admin")->where( $map )->getField($field);
}

//快速获取搜索字段
function search_map()
{
	if(empty($_REQUEST["_search"]) && empty($_REQUEST["pageNum"])) return NULL;

	if(!empty($_REQUEST["_search"]))
	{
		$map = array();
		foreach ($_REQUEST["_search"] as $key=>$value)
		{
			$value = trim($value);
			if(strlen($value) > 0)
			{
				if(strpos($value, "*") !== false)
					$map[$key] = array("like", str_replace("*", "%", $value));
				else
					$map[$key] = $value;
			}
		}
	}

	return $map;
}

//生成列表查询条件
function orderField($field, $default='asc')
{
	if(isset($_POST['orderDirection']) && $_POST['orderField'] == $field)
		return $_POST['orderDirection'] == 'desc' ? 'desc' : 'asc';
	return $default;
}

// 模拟js escape编码
function phpescape($str){
	$sublen=strlen($str);
	$reString="";
	for ($i=0;$i<$sublen;$i++){
		if(ord($str[$i])>=127){
			$tmpString=bin2hex(iconv("utf8","ucs-2",substr($str,$i,2)));    //此处GBK为目标代码的编码格式，请实际情况修改
			if (!eregi("WIN",PHP_OS)){
				$tmpString=substr($tmpString,2,2).substr($tmpString,0,2);
			}
			$reString.="%u".$tmpString;
			$i++;
		} else {
			$reString.="%".dechex(ord($str[$i]));
		}
	}
	return $reString;
}

//截图字符串长度
function subtext($text, $length)
{
    if(mb_strlen($text, 'utf8') > $length)
        return mb_substr($text, 0, $length, 'utf8').'...';
    return $text;
}

//加载扩展函数库
Load('extend');