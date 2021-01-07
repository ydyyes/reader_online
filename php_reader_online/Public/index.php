<?php

// 检测PHP环境
if(version_compare(PHP_VERSION,'5.3.0', '<'))
    die('require PHP > 5.3.0');

if(php_sapi_name() == 'cli')
	$_SERVER['HTTP_HOST'] = 'cli';

//定义项目名称和路径
define('APP_NAME',              'Application');

//全局变量
define('SITE_PATH',             dirname(__DIR__).DIRECTORY_SEPARATOR);
define('APP_PATH',              SITE_PATH.'Application/');
define('DATA_HOME',             SITE_PATH.'Data/');
define('CONF_PATH',             DATA_HOME.'Config/');
define('ATTACH_PATH',           DATA_HOME.'Uploads/');
define('SESSION_PATH',          DATA_HOME.'Session/');
define('EVENT_LOG_PATH',        DATA_HOME.'Log/');

//Composer自动加载代码
if($composer = realpath(SITE_PATH.'vendor/autoload.php')) require $composer; else die('run composer install');

//获取当前运行的域名
define('APP_HOST_NAME',         strtolower(substr($_SERVER['HTTP_HOST'], 0, strpos($_SERVER['HTTP_HOST'], ":") ? strpos($_SERVER['HTTP_HOST'], ":") : strlen($_SERVER['HTTP_HOST']) ) ));
define('APP_HOST_FIX',          substr(APP_HOST_NAME, strpos(APP_HOST_NAME, '.')) );

//获取集群中的php服务器编号，生成不同的编译目录
define('SERVERID',              (isset($_SERVER['SERVERID']) && !empty($_SERVER['SERVERID'])) ? $_SERVER['SERVERID'] : '' );
define('RUNTIME_PATH',          DATA_HOME.'Runtime/'.SERVERID.'/'.APP_HOST_NAME.'/');

//定义调试模式，如果没有指定app_debug或者未在php-fpm中指定为生产模式
define('APP_DEBUG',             isset($_GET['app_debug']) || !getenv('PRODUCTION'));
define('THINK_PATH',            realpath(SITE_PATH.'/vendor/thinkphp/ThinkPHP').'/');
require(THINK_PATH."/ThinkPHP.php");