<?php
define('BIND_MODULE', 'Cli');
define('BIND_CONTROLLER', 'Repl');

if(php_sapi_name() == 'cli') {
	$_SERVER['HTTP_HOST'] = 'cli';
	require 'Public/index.php';
}