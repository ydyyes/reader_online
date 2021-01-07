<?php
/**
 * @param int $length
 * @return string
 */
function salt( $length = 4 ) {
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $salt ='';
    for ( $i = 0; $i < $length; $i++ )
    {
        $salt .= $chars[ mt_rand(0, strlen($chars) - 1) ];
    }
    return $salt;
}
/*
 * 0:成功
 * 300:用户
 * 400:一般错误
 * 500:内部错误
 * 600:订单
 *
 * 800:支付
 *
 * */
function error_msg( $errorno ){
    $msg = [
        '0'      =>'操作成功',
        '200'    =>'操作成功',
        '201'    =>'支付已经成功',
        '2001'   =>'操作失败',
        '300100' =>'用户唯一标识别为空',
        '300101' =>'请求类型不正确',
        '300102' =>'操作失败请稍后重试',
        '300103' =>'登陆失败',
        '300104' =>'手机号未绑定或者输入有误',
        '300105' => '密码格式错误,只含有数字、字母、下划线,6-15位',
        '300106' => '俩次输入不一致',
        '300107' => '手机号已经被绑定',
        '300108' => 'Token失效或者不存在',
        '300109' => '该用户已经绑定过手机号或者该手机号已经绑定',
        '300110' => '登录设备过多',
        '300111' => '用户不可用',
        '300112' => '手机号不存在',
        '300113' => '金币不足',
        '300114' => '异常,请重新登陆',
        '300115' => '用户昵称过长',
        '400100' => '参数错误',
        '400101' => '参数不能为空',
        '400102' => '手机号格式不正确',
        '400103' => '参数必须为正整数',
        '400104' => '数据不存在或者已经下架',
        '400105' => '该栏目不存在或者已经下架',
        '400106' => '没有数据',
        '400108' => '没有找到章节列表',
        '400107' => '已经添加了,不能重复添加',
        '400109' => '内容长度不能低于10或者超过200',
        '400110' => '验证码发送次数超限',
        '400111' => '验证码错误',
        '400112' => '频繁发送验证码',
        '400113' => '超过次数',
        '400114' => '操作太频繁',
        '400115' => '请求错误',
        '400116' => '邀请码错误',
        '400117' => '已经完成过邀请任务',
        '400118' => '该书添加书签过多,请删除后重试',
        '400119' => '商品不存在或者已经下架',
        '600101' => '订单创建失败',
        '600102' => '操作失败,首次充值才可以使用',
        '600103' => '查询订单有误',
        '500101' => 'sign不成功',
        '500102' => '网络不通,请稍后再试',
        '500103' => 'sign没有验证通过'
    ];

    return $msg[$errorno];
}

function query_order_msg( $errorno ){
    $msg = [
        '0'      =>'订单待支付',
        '1'      =>'订单支付中',
        '2'      =>'订单支付成功,正在充值',
        '3'      =>'订单支付失败',
        '4'      =>'订单退款',
        '5'      =>'订单关闭',
        '6'      =>'订单撤销',
        '7'      =>'订单取消',
        '8'      =>'订单异常'
    ];

    return $msg[$errorno]?:'订单异常';
}

function payStatus($v){

    $v['create_time'] =date('Y-m-d H:i:s',$v['create_time']);
    return $v;
}

/**
 * HTTP 状态吗
 */

function http_code($num)
{
    $http = array(
        100 => "HTTP/1.1 100 Continue",
        101 => "HTTP/1.1 101 Switching Protocols",
        200 => "HTTP/1.1 200 OK",
        201 => "HTTP/1.1 201 Created",
        202 => "HTTP/1.1 202 Accepted",
        203 => "HTTP/1.1 203 Non-Authoritative Information",
        204 => "HTTP/1.1 204 No Content",
        205 => "HTTP/1.1 205 Reset Content",
        206 => "HTTP/1.1 206 Partial Content",
        300 => "HTTP/1.1 300 Multiple Choices",
        301 => "HTTP/1.1 301 Moved Permanently",
        302 => "HTTP/1.1 302 Found",
        303 => "HTTP/1.1 303 See Other",
        304 => "HTTP/1.1 304 Not Modified",
        305 => "HTTP/1.1 305 Use Proxy",
        307 => "HTTP/1.1 307 Temporary Redirect",
        400 => "HTTP/1.1 400 Bad Request",
        401 => "HTTP/1.1 401 Unauthorized",
        402 => "HTTP/1.1 402 Payment Required",
        403 => "HTTP/1.1 403 Forbidden",
        404 => "HTTP/1.1 404 Not Found",
        405 => "HTTP/1.1 405 Method Not Allowed",
        406 => "HTTP/1.1 406 Not Acceptable",
        407 => "HTTP/1.1 407 Proxy Authentication Required",
        408 => "HTTP/1.1 408 Request Time-out",
        409 => "HTTP/1.1 409 Conflict",
        410 => "HTTP/1.1 410 Gone",
        411 => "HTTP/1.1 411 Length Required",
        412 => "HTTP/1.1 412 Precondition Failed",
        413 => "HTTP/1.1 413 Request Entity Too Large",
        414 => "HTTP/1.1 414 Request-URI Too Large",
        415 => "HTTP/1.1 415 Unsupported Media Type",
        416 => "HTTP/1.1 416 Requested range not satisfiable",
        417 => "HTTP/1.1 417 Expectation Failed",
        500 => "HTTP/1.1 500 Internal Server Error",
        501 => "HTTP/1.1 501 Not Implemented",
        502 => "HTTP/1.1 502 Bad Gateway",
        503 => "HTTP/1.1 503 Service Unavailable",
        504 => "HTTP/1.1 504 Gateway Time-out"
    );
   return $http[$num];
}

/*
 * 章节详情换取link
 */

function get_chapter_info($path_chapter){

    if(preg_match('/\.\/data_center\/ZS\d?\//',$path_chapter)){
        $url=  preg_replace('/\.\/data_center\/ZS\d?\//',C('F_CDN'),    $path_chapter);
    }else{
        $url =  setImg($path_chapter);
    }
    return $url;
}

function _call_var_filters(&$value)
{
	$value = dhtmlspecialchars($value);
}
function setImg($img){

    if(preg_match('/(\.\/jpg\/)/',$img)){
        $img=  str_replace("./",C('F_CDN'),$img);
    }else{
        $img = strrpos($img, 'http') ? $img : cdn('ATTACH') . $img;
    }

    return $img;
}

function getMonogram(){
    $monogram = ['Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V'
                ,'B','N','M','1','2','3','4','5','6','7','8','9','0'];
    $rand = array_rand($monogram,6);
    $code = '';
    for ($i=0 ;$i < 6 ;$i++){
        $code .= $monogram[$rand[$i]];
    }
    return $code;
}

function fetchIndex($path){

    if(preg_match('/\/home\/data_center\/ZS\d?\//',$path)){
        $path = preg_replace ('/\/home\/data_center\/ZS\d?\//',C('IP_AC'),$path);
    }else{
        $path = strrpos($path, 'http') ? $path : cdn('ATTACH') . $path;
    }

    return $path;
}



function callbackImg($v){

    if(preg_match('/(\.\/jpg\/)/',$v['cover'])){
        $v['cover'] =  str_replace("./",C('F_CDN'),$v['cover']);
    }else{
        $v['cover'] = strrpos($v['cover'], 'http') ? $v['cover'] : cdn('ATTACH') . $v['cover'];
    }
    return $v;
}

/**
 * 对内容进行安全处理
 * @param string|array $string 要处理的字符串或者数组
 * @param $string $flags 指定标记
 */
function dhtmlspecialchars($string, $flags = null)
{
	if(is_array($string)) {
		foreach($string as $key => $val) {
			$string[$key] = dhtmlspecialchars($val, $flags);
		}
	} else {
		if($flags === null) {
			$string = str_replace(array('&', '"', '<', '>'), array('&amp;', '&quot;', '&lt;', '&gt;'), $string);
			if(strpos($string, '&amp;#') !== false) {
				$string = preg_replace('/&amp;((#(\d{3,5}|x[a-fA-F0-9]{4}));)/', '&\\1', $string);
			}
		} else {
			if(PHP_VERSION < '5.4.0') {
				$string = htmlspecialchars($string, $flags);
			} else {
				if(strtolower(CHARSET) == 'utf-8') {
					$charset = 'UTF-8';
				} else {
					$charset = 'ISO-8859-1';
				}
				$string = htmlspecialchars($string, $flags, $charset);
			}
		}
	}
	return $string;
}

/**
 * 输出安全的html代码，如保留br，p等无安全风险的html代码
 * @param string $text
 * @param string $tags
 * @return mixed
 */
function h($text, $tags = null) {
	$text	=	trim($text);
	//完全过滤注释
	$text	=	preg_replace('/<!--?.*-->/','',$text);
	//完全过滤动态代码
	$text	=	preg_replace('/<\?|\?'.'>/','',$text);
	//完全过滤js
	$text	=	preg_replace('/<script?.*\/script>/','',$text);

	$text	=	str_replace('[','&#091;',$text);
	$text	=	str_replace(']','&#093;',$text);
	$text	=	str_replace('|','&#124;',$text);
	//过滤换行符
	$text	=	preg_replace('/\r?\n/','',$text);
	//br
	$text	=	preg_replace('/<br(\s\/)?'.'>/i','[br]',$text);
	$text	=	preg_replace('/<p(\s\/)?'.'>/i','[br]',$text);
	$text	=	preg_replace('/(\[br\]\s*){10,}/i','[br]',$text);
	//过滤危险的属性，如：过滤on事件lang js
	while(preg_match('/(<[^><]+)( lang|on|action|background|codebase|dynsrc|lowsrc)[^><]+/i',$text,$mat)){
		$text=str_replace($mat[0],$mat[1],$text);
	}
	while(preg_match('/(<[^><]+)(window\.|javascript:|js:|about:|file:|document\.|vbs:|cookie)([^><]*)/i',$text,$mat)){
		$text=str_replace($mat[0],$mat[1].$mat[3],$text);
	}
	if(empty($tags)) {
		$tags = 'table|td|th|tr|i|b|u|strong|img|p|br|div|strong|em|ul|ol|li|dl|dd|dt|a';
	}
	//允许的HTML标签
	$text	=	preg_replace('/<('.$tags.')( [^><\[\]]*)>/i','[\1\2]',$text);
	$text = preg_replace('/<\/('.$tags.')>/Ui','[/\1]',$text);
	//过滤多余html
	$text	=	preg_replace('/<\/?(html|head|meta|link|base|basefont|body|bgsound|title|style|script|form|iframe|frame|frameset|applet|id|ilayer|layer|name|script|style|xml)[^><]*>/i','',$text);
	//过滤合法的html标签
	while(preg_match('/<([a-z]+)[^><\[\]]*>[^><]*<\/\1>/i',$text,$mat)){
		$text=str_replace($mat[0],str_replace('>',']',str_replace('<','[',$mat[0])),$text);
	}
	//转换引号
	while(preg_match('/(\[[^\[\]]*=\s*)(\"|\')([^\2=\[\]]+)\2([^\[\]]*\])/i',$text,$mat)){
		$text=str_replace($mat[0],$mat[1].'|'.$mat[3].'|'.$mat[4],$text);
	}
	//过滤错误的单个引号
	while(preg_match('/\[[^\[\]]*(\"|\')[^\[\]]*\]/i',$text,$mat)){
		$text=str_replace($mat[0],str_replace($mat[1],'',$mat[0]),$text);
	}
	//转换其它所有不合法的 < >
	$text	=	str_replace('<','&lt;',$text);
	$text	=	str_replace('>','&gt;',$text);
	$text	=	str_replace('"','&quot;',$text);
	//反转换
	$text	=	str_replace('[','<',$text);
	$text	=	str_replace(']','>',$text);
	$text	=	str_replace('|','"',$text);
	//过滤多余空格
	$text	=	str_replace('  ',' ',$text);
	return $text;
}

/**
 * UBB转换成HTML
 * @param string $Text
 * @return mixed
 */
function ubb($Text)
{
	$Text = trim ( $Text );
	$Text = preg_replace ( "/\\t/is", "  ", $Text );
	$Text = preg_replace ( "/\[h1\](.+?)\[\/h1\]/is", "<h1>\\1</h1>", $Text );
	$Text = preg_replace ( "/\[h2\](.+?)\[\/h2\]/is", "<h2>\\1</h2>", $Text );
	$Text = preg_replace ( "/\[h3\](.+?)\[\/h3\]/is", "<h3>\\1</h3>", $Text );
	$Text = preg_replace ( "/\[h4\](.+?)\[\/h4\]/is", "<h4>\\1</h4>", $Text );
	$Text = preg_replace ( "/\[h5\](.+?)\[\/h5\]/is", "<h5>\\1</h5>", $Text );
	$Text = preg_replace ( "/\[h6\](.+?)\[\/h6\]/is", "<h6>\\1</h6>", $Text );
	$Text = preg_replace ( "/\[separator\]/is", "", $Text );
	$Text = preg_replace ( "/\[center\](.+?)\[\/center\]/is", "<center>\\1</center>", $Text );
	$Text = preg_replace ( "/\[url=http:\/\/([^\[]*)\](.+?)\[\/url\]/is", "<a href=\"http://\\1\" target=_blank>\\2</a>", $Text );
	$Text = preg_replace ( "/\[url=([^\[]*)\](.+?)\[\/url\]/is", "<a href=\"http://\\1\" target=_blank>\\2</a>", $Text );
	$Text = preg_replace ( "/\[url\]http:\/\/([^\[]*)\[\/url\]/is", "<a href=\"http://\\1\" target=_blank>\\1</a>", $Text );
	$Text = preg_replace ( "/\[url\]([^\[]*)\[\/url\]/is", "<a href=\"\\1\" target=_blank>\\1</a>", $Text );
	$Text = preg_replace ( "/\[img\](.+?)\[\/img\]/is", "<img src=\\1>", $Text );
	$Text = preg_replace ( "/\[color=(.+?)\](.+?)\[\/color\]/is", "<font color=\\1>\\2</font>", $Text );
	$Text = preg_replace ( "/\[size=(.+?)\](.+?)\[\/size\]/is", "<font size=\\1>\\2</font>", $Text );
	$Text = preg_replace ( "/\[sup\](.+?)\[\/sup\]/is", "<sup>\\1</sup>", $Text );
	$Text = preg_replace ( "/\[sub\](.+?)\[\/sub\]/is", "<sub>\\1</sub>", $Text );
	$Text = preg_replace ( "/\[pre\](.+?)\[\/pre\]/is", "<pre>\\1</pre>", $Text );
	$Text = preg_replace ( "/\[email\](.+?)\[\/email\]/is", "<a href='mailto:\\1'>\\1</a>", $Text );
	$Text = preg_replace ( "/\[colorTxt\](.+?)\[\/colorTxt\]/eis", "color_txt('\\1')", $Text );
	$Text = preg_replace ( "/\[emot\](.+?)\[\/emot\]/eis", "emot('\\1')", $Text );
	$Text = preg_replace ( "/\[i\](.+?)\[\/i\]/is", "<i>\\1</i>", $Text );
	$Text = preg_replace ( "/\[u\](.+?)\[\/u\]/is", "<u>\\1</u>", $Text );
	$Text = preg_replace ( "/\[b\](.+?)\[\/b\]/is", "<b>\\1</b>", $Text );
	$Text = preg_replace ( "/\[quote\](.+?)\[\/quote\]/is", " <div class='quote'><h5>引用:</h5><blockquote>\\1</blockquote></div>", $Text );
	$Text = preg_replace ( "/\[code\](.+?)\[\/code\]/eis", "highlight_code('\\1')", $Text );
	$Text = preg_replace ( "/\[php\](.+?)\[\/php\]/eis", "highlight_code('\\1')", $Text );
	$Text = preg_replace ( "/\[sig\](.+?)\[\/sig\]/is", "<div class='sign'>\\1</div>", $Text );
	$Text = preg_replace ( "/\\n/is", "<br/>", $Text );
	
	return $Text;
}

/**
 * 对前台输出的内容进行安全过滤
 * encode:输出dhtmlspecialchars编码后的文字(默认)
 * text:输出带纯文本，即过滤掉所有代码
 * safe:输出安全的html代码，如保留br，p等无安全风险的html代码
 * @param mixed $content
 * @param string $output
 */
function safe($content, $output = 'encode')
{
	switch ($output)
	{
		case 'encode':
			return dhtmlspecialchars($content, ENT_QUOTES);
		case 'text':
			return dhtmlspecialchars(strip_tags($content));
		case 'safe':
			return h($content);
		default:
			return dhtmlspecialchars($content);
	}
}

/**
 * 显示友好的时间
 * @param String $time 预处理内容
 */
function time_ago($time) {
	if(!ctype_digit((string)$time))
		$time = strtotime($time);

    $t = time() - $time;

    if ($t == 0)
        $text = '刚刚';
    elseif ($t < 60)
        $text = $t . '秒前';
    elseif ($t < 60 * 60)
        $text = floor($t / 60) . '分钟前';
    elseif ($t < 60 * 60 * 24)
        $text = floor($t / (60 * 60)) . '小时前';
    elseif ($t < 60 * 60 * 24 * 2)
        $text = '昨天 ' . date('H:i', $time);
    elseif ($t < 60 * 60 * 24 * 3)
        $text = '前天 ' . date('H:i', $time);
    elseif ($t < 60 * 60 * 24 * 30)
        $text = date('m月d日 H:i', $time);
    elseif ($t < 60 * 60 * 24 * 365)
        $text = date('m月d日1', $time);
    else
        $text = date('Y年m月d日2', $time);
    return $text;
}

/**
 * 加载助手类
 * @param mixed $helper
 * @param bool $init 是否实例化
 */
function helper($helper, $init=true)
{
	$class = "\Helper\\$helper";
	return new $class;
}

/**
 * 静态文件CDNURL生成
 * 可以针对静态资源、上传的文件进行单独的域名绑定
 * @param $path
 * @param string $subPath
 * @return string
 */
function cdn($path, $subPath = '')
{
    $url = C('CDN_URL');

    $path = strtoupper($path);
    $subPath = strtoupper($subPath);
    if (empty($subPath) || !isset($url[$path][$subPath]))
    {
        $subPath = 'DEFAULT';
    }

    $link = !empty($url[$path][$subPath]) ? $url[$path][$subPath] : '/'.strtolower($path);

    if($link[0] == '/')
        $link = sprintf('http://%s%s', $_SERVER['HTTP_HOST'], $link);

    if($path == 'PUBLIC')
        $link = sprintf('%s/%s', rtrim($link, '/'), C('DEFAULT_THEME'));


    return $link;
}

/**
 * 从HTTP头信息中获取客户端信息
 * 
 * @since 1.0
 * @return array
 */
function get_headers_info()
{
	$info = array();
	$header = array('imei', 'imsi', 'uuid', 'vcode', 'vname',  'model', 'manuFacturer', 'brand', 'resolution',  'sdk', 'channel', 'net','requestTime');
	foreach ($header as $v)
	{
		$k = sprintf("HTTP_%s", strtoupper($v));
		if(isset($_SERVER[$k]))
			$info[$v] = $_SERVER[$k];
		else
			$info[$v] = isset($_REQUEST[$v]) ? $_REQUEST[$v] : '';
			//有的接口头信息里无imei和vcode信息,从参数里获得
	}
	return $info;
}

/**
 * authcode加密
 * @param  string
 * @return string
 * @author xuliang<xugnail@163.com>
 */
function authcode($string, $operation = 'DECODE', $key = '', $expiry = 0)
{
	$ckey_length = 4;

	$key = md5($key ? $key : C('AUTHCODE_KEY'));
	$keya = md5(substr($key, 0, 16));
	$keyb = md5(substr($key, 16, 16));
	$keyc = $ckey_length ? ($operation == 'DECODE' ? substr($string, 0, $ckey_length): substr(md5(microtime()), -$ckey_length)) : '';

	$cryptkey = $keya.md5($keya.$keyc);
	$key_length = strlen($cryptkey);

	$string = $operation == 'DECODE' ? base64_decode(substr($string, $ckey_length)) : sprintf('%010d', $expiry ? $expiry + time() : 0).substr(md5($string.$keyb), 0, 16).$string;
	$string_length = strlen($string);

	$result = '';
	$box = range(0, 255);

	$rndkey = array();
	for($i = 0; $i <= 255; $i++) {
		$rndkey[$i] = ord($cryptkey[$i % $key_length]);
	}

	for($j = $i = 0; $i < 256; $i++) {
		$j = ($j + $box[$i] + $rndkey[$i]) % 256;
		$tmp = $box[$i];
		$box[$i] = $box[$j];
		$box[$j] = $tmp;
	}

	for($a = $j = $i = 0; $i < $string_length; $i++) {
		$a = ($a + 1) % 256;
		$j = ($j + $box[$a]) % 256;
		$tmp = $box[$a];
		$box[$a] = $box[$j];
		$box[$j] = $tmp;
		$result .= chr(ord($string[$i]) ^ ($box[($box[$a] + $box[$j]) % 256]));
	}

	if($operation == 'DECODE') {
		if((substr($result, 0, 10) == 0 || substr($result, 0, 10) - time() > 0) && substr($result, 10, 16) == substr(md5(substr($result, 26).$keyb), 0, 16)) {
			return substr($result, 26);
		} else {
			return '';
		}
	} else {
		return $keyc.str_replace('=', '', base64_encode($result));
	}
}

/**
 * 数组大小写递归转换
 * @param array $array
 * @param $mode boole CASE_LOWER|CASE_UPPER
 */
function array_change_key_case_recursive(array $array, $mode=CASE_LOWER)
{
	if(!is_array($array))
		return $array;
	$mode = $mode == CASE_LOWER ? CASE_LOWER : CASE_UPPER;
	foreach ($array as $k => $v)
		$ret[$mode == CASE_UPPER ? strtoupper($k) : strtolower($k) ] = array_change_key_case_recursive($v, $mode);
	return (array)$ret;
}

/**
 * 计算到指定时间还剩下的时间秒数
 * 多用于当天的缓存
 * @param string $day
 */
function timeleft($day=null)
{
	$day = empty($day) ? strtotime(date("Y-m-d")) + 86400 : strtotime($day);
	return $day - time();
}

/**
 * 获取系统配置项
 * @param string $field     获取的key
 * @param string $default   无返回值的时候，使用的默认值
 * @return mixed $value array($field=>$value)
 */
function sysconfig($field, $default=null)
{
	return D("SysConfig")->getValue($field, $default);
}

/**
 * aapt指令获取信息
 * @param string $file file path
 * @return mixed
 */
function aapt($file)
{
    $cmd = sprintf("/usr/bin/aapt dump badging '%s'", $file);
    $return = shell_exec($cmd);
    if (null === $return)
    {
        \Think\Log::write($cmd, \Think\Log::WARN);
        \Think\Log::write($return, \Think\Log::WARN);
    }

    return strlen($return) > 0 ? $return : '';
}

/**
 * 处理aapt命令执行结果，提取有效信息
 *
 * @param $info
 * @return array
 */
function get_apk_info($info)
{
    if (empty($info))
    {
        return [];
    }
    $apkInfo = [];
    $reg['pname'] = "/package\: name=\'([\w\.]+)\'/i";
    $reg['vname'] = "/versionName=\'([0-9._a-zA-Z\(\)]+)\'/";
    $reg['vcode'] = "/versionCode=\'([0-9]+)\'/";
    $reg['name'] = "/application-label\:\'(.*)\'/i";
    $reg['icon'] = "/icon=\'(.*?)\'/i";

    foreach ($reg as $k => $v)
    {
        preg_match($v, $info, $match);
        if (!empty($match[1]))
        {
            $apkInfo[$k] = $match[1];
        }
        continue;
    }

    return $apkInfo;
}

function get_icon($tarfile, $icon, $path)
{
    $cmd = sprintf("unzip -o '%s' '%s' -d '%s'", $tarfile , $icon, "/tmp/icon/");
    $return = shell_exec($cmd);
    $cmd2 = sprintf("cp /tmp/icon/%s %s", $icon, $path . basename($icon));
    $return2 = shell_exec($cmd2);
    \Think\Log::write($cmd . '--result--' . $return, \Think\Log::WARN);
    \Think\Log::write($cmd2 . '--result--' . $return2, \Think\Log::WARN);
}

function get_all_geo_abbr()
{
    //共248个国家简写
    $geos = "ar,au,at,bh,br,cl,cc,hm,co,cz,ec,fi,fr,de,gh,hu,in,id,ie,jp,jo,ke,lu,my,mx,nl,ng,no,pa,ph,pl,pt,ro,sa,sg,vn,si,za,es,ch,th,ae,mk,eg,us,ad,af,ag,ai,al,am,ao,aq,as,aw,ax,az,ba,bb,bd,be,bf,bg,bi,bj,bl,bm,bn,bo,bq,bs,bt,bv,bw,by,bz,ca,cd,cf,cg,ci,ck,cm,cn,cr,cu,cv,cw,cx,cy,dj,dk,dm,do,dz,ee,eh,er,et,fj,fk,fm,fo,ga,gb,gd,ge,gf,gg,gi,gl,gm,gn,gp,gq,gr,gs,gt,gu,gw,gy,hk,hn,hr,ht,il,im,io,iq,ir,is,it,je,jm,kg,kh,ki,km,kn,kp,kr,kw,ky,kz,la,lb,lc,li,lk,lr,ls,lt,lv,ly,ma,mc,md,me,mf,mg,mh,ml,mm,mn,mo,mp,mq,mr,ms,mt,mu,mv,mw,mz,na,nc,ne,nf,ni,np,nr,nu,nz,om,pe,pf,pg,pk,pm,pn,pr,ps,pw,py,qa,re,rs,ru,rw,sb,sc,sd,se,sh,sj,sk,sl,sm,sn,so,sr,ss,st,sv,sx,sy,sz,tc,td,tf,tg,tj,tk,tl,tm,tn,to,tr,tt,tv,tw,tz,ua,ug,um,uy,uz,va,vc,ve,vg,vi,vu,wf,ws,ye,yt,zm,zw,zz";
    return $geos;
}

function get_geo_full_name()
{
    $fullName = '{"AR":"Argentina","AU":"Australia","AT":"Austria","BH":"Bahrain","BR":"Brazil","CL":"Chile",'.
    '"CO":"Colombia","CZ":"Czech Republic","EC":"Ecuador","FI":"Finland","FR":"France","DE":"Germany",'.
    '"GH":"Ghana","HU":"Hungary","IN":"India","ID":"Indonesia","IE":"Ireland","JP":"Japan","JO":"Jordan",'.
    '"KE":"Kenya","LU":"Luxembourg","MY":"Malaysia","MX":"Mexico","NL":"Netherlands","NG":"Nigeria",'.
    '"NO":"Norway","PA":"Panama","PH":"Philippines","PL":"Poland","PT":"Portugal","RO":"Romania",'.
    '"SA":"Saudi Arabia","SG":"Singapore","VN":"Viet nam","SI":"Slovenia","ZA":"South Africa","ES":"Spain",'.
    '"CH":"Switzerland","TH":"Thailand","AE":"United Arab Emirates","MK":"Macedonia - The Frm Yugoslav Rep Of",'.
    '"EG":"Egypt","US":"United States","AD":"Andorra","AF":"Afghanistan","AG":"Antigua and Barbuda","AI":"Anguilla",'.
    '"AL":"Albania","AM":"Armenia","AO":"Angola","AQ":"Antarctica","AS":"American Samoa","AW":"Aruba",'.
    '"AX":"Aland Islands","AZ":"Azerbaijan","BA":"Bosnia and Herzegovina","BB":"Barbados","BD":"Bangladesh",'.
    '"BE":"Belgium","BF":"Burkina Faso","BG":"Bulgaria","BI":"Burundi","BJ":"Benin","BL":"Saint Barthelemy",'.
    '"BM":"Bermuda","BN":"Brunei Darussalam","BO":"Bolivia, Plurinational State of","BQ":"Bonaire, Sint Eustatius and Saba",'.
    '"BS":"Bahamas","BT":"Bhutan","BV":"Bouvet Island","BW":"Botswana","BY":"Belarus","BZ":"Belize","CA":"Canada",'.
    '"CD":"Congo, the Democratic Republic of the","CF":"Central African Republic","CG":"Congo","CI":"Cote d\'Ivoire/Ivory Coast",'.
    '"CK":"Cook Islands","CM":"Cameroon","CN":"China","CR":"Costa Rica","CU":"Cuba","CV":"Cape Verde","CW":"Curaçao",'.
    '"CX":"Christmas Island","CY":"Cyprus","DJ":"Djibouti","DK":"Denmark","DM":"Dominica","DO":"Dominican Republic",'.
    '"DZ":"Algeria","EE":"Estonia","EH":"Western Sahara","ER":"Eritrea","ET":"Ethiopia","FJ":"Fiji","FK":"Falkland Islands (Malvinas)",'.
    '"FM":"Micronesia, Federated States of","FO":"Faroe Islands","GA":"Gabon","GB":"United Kingdom","GD":"Grenada","GE":"Georgia",'.
    '"GF":"French Guiana","GG":"Guernsey","GI":"Gibraltar","GL":"Greenland","GM":"Gambia","GN":"Guinea",'.
    '"GP":"Guadeloupe","GQ":"Equatorial Guinea","GR":"Greece","GS":"South Georgia and the South Sandwich Islands",'.
    '"GT":"Guatemala","GU":"Guam","GW":"Guinea-Bissau","GY":"Guyana","HK":"Hong Kong","HN":"Honduras","HR":"Croatia",'.
    '"HT":"Haiti","IL":"Israel","IM":"Isle of Man","IO":"British Indian Ocean Territory","IQ":"Iraq",'.
    '"IR":"Iran, Islamic Republic of","IS":"Iceland","IT":"Italy","JE":"Jersey","JM":"Jamaica","KG":"Kyrgyzstan",'.
    '"KH":"Cambodia","KI":"Kiribati","KM":"Comoros","KN":"Saint Kitts and Nevis","KP":"Korea, Democratic People\'s Republic of",'.
    '"KR":"Korea, Republic of","KW":"Kuwait","KY":"Cayman Islands","KZ":"Kazakhstan","LA":"Lao People\'s Democratic Republic",'.
    '"LB":"Lebanon","LC":"Saint Lucia","LI":"Liechtenstein","LK":"Sri Lanka","LR":"Liberia","LS":"Lesotho","LT":"Lithuania",'.
    '"LV":"Latvia","LY":"Libya","MA":"Morocco","MC":"Monaco","MD":"Moldova, Republic of","ME":"Montenegro",'.
    '"MF":"Saint Martin (French part)","MG":"Madagascar","MH":"Marshall Islands","ML":"Mali","MM":"Myanmar",'.
    '"MN":"Mongolia","MO":"Macao","MP":"Northern Mariana Islands","MQ":"Martinique","MR":"Mauritania",'.
    '"MS":"Montserrat","MT":"Malta","MU":"Mauritius","MV":"Maldives","MW":"Malawi","MZ":"Mozambique",'.
    '"NA":"Namibia","NC":"New Caledonia","NE":"Niger","NF":"Norfolk Island","NI":"Nicaragua","NP":"Nepal","NR":"Nauru",'.
    '"NU":"Niue","NZ":"New Zealand","OM":"Oman","PE":"Peru","PF":"French Polynesia","PG":"Papua New Guinea",'.
    '"PK":"Pakistan","PM":"Saint Pierre and Miquelon","PN":"Pitcairn","PR":"Puerto Rico","PS":"Palestine, State of",'.
    '"PW":"Palau","PY":"Paraguay","QA":"Qatar","RE":"Reunion","RS":"Serbia","RU":"Russian Federation","RW":"Rwanda",'.
    '"SB":"Solomon Islands","SC":"Seychelles","SD":"Sudan","SE":"Sweden","SH":"Saint Helena, Ascension and Tristan da Cunha",'.
    '"SJ":"Svalbard and Jan Mayen","SK":"Slovakia","SL":"Sierra Leone","SM":"San Marino","SN":"Senegal","SO":"Somalia",'.
    '"SR":"Suriname","SS":"South Sudan","ST":"Sao Tome and Principe","SV":"El Salvador","SX":"Sint Maarten (Dutch part)",'.
    '"SY":"Syrian Arab Republic","SZ":"Swaziland","TC":"Turks and Caicos Islands","TD":"Chad","TF":"French Southern Territories",'.
    '"TG":"Togo","TJ":"Tajikistan","TK":"Tokelau","TL":"Timor-Leste","TM":"Turkmenistan","TN":"Tunisia","TO":"Tonga",'.
    '"TR":"Turkey","TT":"Trinidad and Tobago","TV":"Tuvalu","TW":"Taiwan, Province of China","TZ":"Tanzania, United Republic of",'.
    '"UA":"Ukraine","UG":"Uganda","UM":"United States Minor Outlying Islands","UY":"Uruguay","UZ":"Uzbekistan","VA":"Holy See (Vatican City State)",'.
    '"VC":"Saint Vincent and the Grenadines","VE":"Venezuela, Bolivarian Republic of","VG":"Virgin Islands, British","VI":"Virgin Islands, U.S.",'.
    '"VU":"Vanuatu","WF":"Wallis and Futuna","WS":"Samoa","YE":"Yemen","YT":"Mayotte","ZM":"Zambia","ZW":"Zimbabwe","ZZ":"ZZ"}';
    return $fullName;
}

/**
 * 国家3位简称转换成2位的
 * @param string $country  国家简称3位的
 * @return string
 */
function get_geo_32_name($country='')
{
    $parseName = geo32name();
    if(empty($country))
    {
        return $parseName;
    }else{
        $country = strtoupper($country);
        return $parseName[$country];
    }
}

function geo32name() {
    $parseName = '{"AND":"AD","ARE":"AE","AFG":"AF","ATG":"AG","AIA":"AI","ALB":"AL","ARM":"AM","AGO":"AO","ATA":"AQ","ARG":"AR","ASM":"AS","AUT":"AT",
        "AUS":"AU","ABW":"AW","ALA":"AX","AZE":"AZ","BIH":"BA","BRB":"BB","BGD":"BD","BEL":"BE","BFA":"BF","BGR":"BG","BHR":"BH","BDI":"BI","BEN":"BJ",
        "BLM":"BL","BMU":"BM","BRN":"BN","BOL":"BO","BES":"BQ","BRA":"BR","BHS":"BS","BTN":"BT","BVT":"BV","BWA":"BW","BLR":"BY","BLZ":"BZ","CAN":"CA",
        "CCK":"CC","COD":"CD","CAF":"CF","COG":"CG","CHE":"CH","CIV":"CI","COK":"CK","CHL":"CL","CMR":"CM","CHN":"CN","COL":"CO","CRI":"CR","CUB":"CU",
        "CPV":"CV","CUW":"CW","CXR":"CX","CYP":"CY","CZE":"CZ","DEU":"DE","DJI":"DJ","DNK":"DK","DMA":"DM","DOM":"DO","DZA":"DZ","ECU":"EC","EST":"EE",
        "EGY":"EG","ESH":"EH","ERI":"ER","ESP":"ES","ETH":"ET","FIN":"FI","FJI":"FJ","FLK":"FK","FSM":"FM","FRO":"FO","FRA":"FR","GAB":"GA","GBR":"GB",
        "GRD":"GD","GEO":"GE","GUF":"GF","GGY":"GG","GHA":"GH","GIB":"GI","GRL":"GL","GMB":"GM","GIN":"GN","GLP":"GP","GNQ":"GQ","GRC":"GR","SGS":"GS",
        "GTM":"GT","GUM":"GU","GNB":"GW","GUY":"GY","HKG":"HK","HMD":"HM","HND":"HN","HRV":"HR","HTI":"HT","HUN":"HU","IDN":"ID","IRL":"IE","ISR":"IL",
        "IMN":"IM","IND":"IN","IOT":"IO","IRQ":"IQ","IRN":"IR","ISL":"IS","ITA":"IT","JEY":"JE","JAM":"JM","JOR":"JO","JPN":"JP","KEN":"KE","KGZ":"KG",
        "KHM":"KH","KIR":"KI","COM":"KM","KNA":"KN","PRK":"KP","KOR":"KR","KWT":"KW","CYM":"KY","KAZ":"KZ","LAO":"LA","LBN":"LB","LCA":"LC","LIE":"LI",
        "LKA":"LK","LBR":"LR","LSO":"LS","LTU":"LT","LUX":"LU","LVA":"LV","LBY":"LY","MAR":"MA","MCO":"MC","MDA":"MD","MNE":"ME","MAF":"MF","MDG":"MG",
        "MHL":"MH","MKD":"MK","MLI":"ML","MMR":"MM","MNG":"MN","MAC":"MO","MNP":"MP","MTQ":"MQ","MRT":"MR","MSR":"MS","MLT":"MT","MUS":"MU","MDV":"MV",
        "MWI":"MW","MEX":"MX","MYS":"MY","MOZ":"MZ","NAM":"NA","NCL":"NC","NER":"NE","NFK":"NF","NGA":"NG","NIC":"NI","NLD":"NL","NOR":"NO","NPL":"NP",
        "NRU":"NR","NIU":"NU","NZL":"NZ","OMN":"OM","PAN":"PA","PER":"PE","PYF":"PF","PNG":"PG","PHL":"PH","PAK":"PK","POL":"PL","SPM":"PM","PCN":"PN",
        "PRI":"PR","PSE":"PS","PRT":"PT","PLW":"PW","PRY":"PY","QAT":"QA","REU":"RE","ROU":"RO","SRB":"RS","RUS":"RU","RWA":"RW","SAU":"SA","SLB":"SB",
        "SYC":"SC","SDN":"SD","SWE":"SE","SGP":"SG","SHN":"SH","SVN":"SI","SJM":"SJ","SVK":"SK","SLE":"SL","SMR":"SM","SEN":"SN","SOM":"SO","SUR":"SR",
        "STP":"ST","SLV":"SV","SXM":"SX","SYR":"SY","SWZ":"SZ","TCA":"TC","TCD":"TD","ATF":"TF","TGO":"TG","THA":"TH","TJK":"TJ","TKL":"TK","TLS":"TL",
        "TKM":"TM","TUN":"TN","TON":"TO","TUR":"TR","TTO":"TT","TUV":"TV","TWN":"TW","TZA":"TZ","UKR":"UA","UGA":"UG","UMI":"UM","USA":"US","URY":"UY",
        "UZB":"UZ","VAT":"VA","VCT":"VC","VEN":"VE","VGB":"VG","VIR":"VI","VNM":"VN","VUT":"VU","WLF":"WF","WSM":"WS","YEM":"YE","MYT":"YT","ZAF":"ZA",
        "ZMB":"ZM","ZWE":"ZW"}';
    $parseName = json_decode($parseName, true);
    return $parseName;
}

/**
 * 根据ip 获取国家简称
 * @return string
 */
function get_country_code()
{
    $geo = '';
    $ip = get_client_ip(0,true);
    if (empty($ip))
    {
        return $geo;
    }

    try {
        //首先读取配置文件, 如果没有则去读取SysConfig
        $config_ipip = C('IPIP_SERVICE_URL');
        $ipip = (!empty($config_ipip)) ? $config_ipip : D('SysConfig')->getValue("IPIP_SERVICE_URL");
        if (empty($ipip))
        {
            throw new \Exception("$ipip ipip not exists！");
        }
        $ipip = rtrim($ipip,'/');
        $cmd = "curl -sL -m 2 '{$ipip}/{$ip}'";
        $res = json_decode(`$cmd`, true);
        if (!empty($res) && $res[$ip]['code'])
        {
            $geo = trim(strtolower($res[$ip]['code']));
        }
    } catch (\Exception $e) {
        \Think\Log::write($e->getMessage(), \Think\Log::EMERG);
    }
    return $geo == '*' || empty($res) ? '' : $geo;
}

function sendmail($subject='', $contents='', $to='sendmail@whaledigit.com')
{
    $conf = include CONF_PATH . "email.php";
    $notice = isset($conf['NOTICE']['GENERAL']) ? $conf['NOTICE']['GENERAL'] : $to;
    $email = helper('Email');
    $email->send($notice, $subject, $contents);
}

/**
 * redis 简单自定义扩展使用
 * @param string $host
 * @param string $port
 * @return Redis
 */
function redis_custom($host="",$port="")
{
	try {
		$type = C('DATA_CACHE_TYPE');
		if (empty($host))
		{
			$host = C("{$type}_HOST") ? C("{$type}_HOST") : '127.0.0.1';
			$host = array_map('trim', explode(",", trim($host, ",")));
			$host = array_shift($host);
		}
		if (empty($port))
		{
			$port = C("{$type}_PORT") ? C("{$type}_PORT") : '6379';
		}
		//redis长连接
		$option = ['host'=>$host, 'port'=>$port, 'persistent'=>true];
		$cache = \Think\Cache::getInstance('redis',$option);
	} catch (\Exception $e) {
		\Think\Log::write($e->getMessage(), \Think\Log::EMERG);
		sendmail("REDIS_CUSTOM ERROR!", "host:{$_SERVER['HTTP_HOST']} " . $e->getMessage());
	}
	return $cache;
}

/**
 * gif to png or jpg
 * @param $gif
 * @param string $type
 * @return string
 */
function get_img_from_gif($gif, $type='png')
{
    $im = imagecreatefromgif($gif);
    $tmpDir = $gif;
    if ($im) {
        $tmpDir = strpos($gif, '.') ? substr($gif, 0, strrpos($gif, '.')+1) . $type : $gif . "." . $type;
        if ($type == 'png')
        {
            imagepng($im, $tmpDir);
        } elseif ($type == 'jpg') {
            imagejpeg($im, $tmpDir);
        } else {
            return $gif;
        }
    }
    imagedestroy($im);

    return $tmpDir;
}

/**
 * array chunk
 * @param $arr
 * @param int $size
 * @return array
 */
function arr_chunk($arr, $size = 100)
{
    $chunk = [];
    if (count($arr) > $size)
    {
        $chunk = array_chunk($arr, $size);
    } else {
        $chunk = empty($arr) ? [] : [$arr];
    }

    return $chunk;
}

//对应java用hashcode加密的字符串方法
function hashCode32( $s )
{
    $h = 0;
    $len = strlen($s);
    for($i = 0; $i < $len; $i++)
    {
        $h = overflow32(31 * $h + ord($s[$i]));
    }

    return $h;
}

function overflow32($v)
{
    $v = $v % 4294967296;
    if ($v > 2147483647) return $v - 4294967296;
    elseif ($v < -2147483648) return $v + 4294967296;
    else return $v;
}

function check_phonenum($phone, $geo)
{
    $result = "";
    $phoneUtil = \libphonenumber\PhoneNumberUtil::getInstance();
    try {
        $numberProto = $phoneUtil->parse($phone, strtoupper($geo));
        $isValid = $phoneUtil->isValidNumber($numberProto);
        if ($isValid)
        {
            $result = $phoneUtil->format($numberProto, \libphonenumber\PhoneNumberFormat::E164);
        }
    } catch (\libphonenumber\NumberParseException $e) {
        \Think\Log::write("libphonenumber Exception ". $e->getMessage());
    }

    return $result;
}

function curl($uri, $post=false, $data=[])
{
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $uri);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 1);
    curl_setopt($curl, CURLOPT_TIMEOUT, 3);
    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);//支持链接里的301重定向
    if (true === $post)
    {
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
    }
    $response = curl_exec($curl);
    curl_close($curl);
    return $response;
}

function get_cdn_share_dir($type="pic")
{
    $dir = ATTACH_PATH;
    $apkDir = C('APK_SHARE_DIR');
    $picDir = C('PIC_SHARE_DIR');
    $type = strtolower(trim($type));
    if ($type == 'apk' && !empty($apkDir))
    {
        $dir = $apkDir;
    } elseif ($type == 'pic' && !empty($picDir)) {
        $dir = $picDir;
    }
    if (empty($dir))
    {
        $dir = ATTACH_PATH;
    }
    if (!is_dir($dir))
    {
        mkdir($dir, 0777, true);
    }
    $dir = rtrim($dir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR;
    return $dir;
}

/**
 * 图片命名转换为xx/xx/xxx.ext
 * @param $name
 * @return string
 */
function recreate_img_name($name)
{
    if (!empty($name))
    {
        $first = substr($name, 0, 2);
        $second = substr($name, 2, 2);
        $last = substr($name, 4);
        $name = $first . DIRECTORY_SEPARATOR . $second . DIRECTORY_SEPARATOR . $last;
    }

    return $name;
}

function decompress($file)
{
    $info = pathinfo($file);
    $filepath = $info['dirname'] . "/" . $info['filename'];

    if (!is_dir($filepath))
    {
        mkdir($filepath, 0777, true);
    }

    if ("rar" == $info['extension'])
    {
        $cmd = sprintf("unrar e '%s' '%s'", $file, $info['dirname']);
    } elseif ("zip" == $info['extension']) {
        $cmd = sprintf("unzip -oq '%s' -d '%s'", $file, $info['dirname']);
    }
    $cmd2 = sprintf("ls '%s'|wc -l", $filepath);
    try {
        `$cmd`;
        $count = trim(`$cmd2`);
    } catch (\Exception $e) {
        \Think\Log::write($e->getMessage());
    }

    return ['filepath'=>$filepath, 'count'=>$count];
}