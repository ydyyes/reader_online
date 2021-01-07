<?php
define('BIND_MODULE', 'Cli');

if(php_sapi_name() == 'cli')
{
	$_SERVER['HTTP_HOST'] = 'cli';
	
	//参数伪装，与老版本兼容
	if($_SERVER['argc'] > 1)
	{
		$_SERVER['argc'] = 2;
		$_SERVER['argv'] = array($_SERVER['argv']['0'], join('/',array_slice($_SERVER['argv'], 1)));
	}

	require 'Public/index.php';
}