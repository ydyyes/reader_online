#!/usr/bin/env php
<?php
/**
 * 使用sami模块实现接口api文档生成
 */
if(count($_SERVER["argv"]) == 1)
{
	$command = "./vendor/bin/sami.php update {$argv[0]}";
	
	$fp = popen($command, "r");
	
	//output result in real time
	if( $fp ) {
		while( !feof($fp) ){
			echo fread($fp, 1024);
			flush();
		}
		fclose($fp);
	}
}

require 'vendor/autoload.php';

use Sami\Sami;
use Symfony\Component\Finder\Finder;

$iterator = Finder::create()
    ->files()
    ->name('*.php')
    ->in(__DIR__.'/Application');

return new Sami($iterator, array(
    'theme'			=> 'default',
    'title'			=> 'ThinkPHP GOLD API',
    'build_dir'		=> 'document/php_doc_build',
    'cache_dir'		=> 'document/php_doc_cache',
));