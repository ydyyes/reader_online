<?php
namespace Test\Controller;

/**
 * 环境变量测试工具
 * @author shuhai
 */
class TestEnvController extends BaseController
{
	/**
	 * 测试系统是否已经安装必须的扩展
	 * @author shuhai
	 */
	function test_extension_loaded()
	{
		$ext = ["bcmath", "bz2", "calendar", "Core", "ctype", "curl", "date", "dba", "dom", "ereg",
				"exif", "fileinfo", "filter", "ftp", "gd", "gettext",
				"hash", "iconv", "intl", "json", "ldap", "libxml", "mbstring", "mcrypt",
				"memcache", "memcached", "mhash", "mongo", "mysql", "mysqli", "mysqlnd",
				"odbc", "openssl", "pcntl", "pcre", "PDO", "pdo_mysql", "PDO_ODBC",
				"posix", "readline", "redis", "Reflection", "session", "shmop", "SimpleXML",
				"soap", "sockets", "SPL", "sqlite3", "standard", "sysvmsg", "sysvsem",
				"sysvshm", "tokenizer", "wddx", "xml", "xmlreader", "xmlrpc",
				"xmlwriter", "xsl", "zip", "zlib"];
		
		$result = true;
		foreach ($ext as $e)
		{
			if(extension_loaded($e) == false)
			{
				$result = false;
				printf("\textension %s unloaded%s", $e, PHP_EOL);
			}
		}
		
		return $result;
	}
	
	/**
	 * 测试系统是否已经安装必须的函数
	 * @author shuhai
	 */
	function test_function_exists()
	{
		$ext = [
		    "pcntl_signal", "readline", "imagejpeg", "imagegif", "imagecreatefromjpeg", "shell_exec",
		    "gzcompress"
		];
	
		$result = true;
		foreach ($ext as $e)
		{
			if(function_exists($e) == false)
			{
				$result = false;
				printf("\tfunction %s undefined%s", $e, PHP_EOL);
			}
		}
	
		return $result;
	}
	
	/**
	 * 测试系统是否已经安装必须的类
	 * @author shuhai
	 */
	function test_class_exists()
	{
		$ext = [
		    "Redis", "RedisCluster",
		];
	
		$result = true;
		foreach ($ext as $e)
		{
			if(class_exists($e) == false)
			{
				$result = false;
				printf("\tclass %s undefined%s", $e, PHP_EOL);
			}
		}
	
		return $result;
	}
	
	/**
	 * 测试系统是否已经安装必须的命令
	 * @author shuhai
	 */
	function test_command_exists()
	{
		if(!function_exists('shell_exec'))
			return "EMERG:不支持shell_exec，无法继续";
		
		$ext = [
		    "/bin/sh", "aapt", "composer", "python", "hostname", "curl", "chmod", "unzip", "zip"
		];
		
		$result = true;
		foreach ($ext as $e)
		{
			if($this->command_exists($e) == false)
			{
				$result = false;
				printf("command %s not installed%s", $e, PHP_EOL);
			}
		}
		
		return $result;
	}
	
	protected function command_exists($command)
	{
		return shell_exec("command -v ".$command);
	}
}