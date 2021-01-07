<?php
define('BIND_MODULE', 'Test');

if(@$_SERVER["argv"][1] == 'all')
	define('BIND_CONTROLLER', 'Index');

if(php_sapi_name() == 'cli') {
	$_SERVER['HTTP_HOST'] = 'Test';
	require 'Public/index.php';
}