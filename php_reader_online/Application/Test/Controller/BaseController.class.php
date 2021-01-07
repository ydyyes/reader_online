<?php
namespace Test\Controller;
use Cli\Controller\ClibaseController;

/**
 * 简单的单元测试类，建立的测试用例，需要定义public test_开始的方法
 * 测试成功的方法返回true，失败的返回false，如果返回字符串则直接输出
 * @author shuhai
 */
abstract class BaseController extends ClibaseController
{
	function index()
	{
	    $this->runtest($this);
	}
	
	/**
	 * 
	 * @param string | $this $class
	 */
	protected function runtest($class)
	{
	    $class = new \ReflectionClass($class);
	    
		$instance = $class->newInstance();
		method_exists($instance, "_before") && call_user_func([$instance, "_before"]);
		
		$methods = $class->getMethods();
		foreach ($methods as $k=>$v)
		{
			if(0 !== strpos(strtolower($v->name), "test"))
				continue;
			
			$v = ["name"=>$v->name, "class"=>$v->class, "file"=>$v->getFileName(), "line"=>$v->getStartLine(), "doc"=>$this->parseAnnotations($v->getDocComment())];
			
			//找到以test_开头的函数，开始执行任务
			try {
				$result = call_user_func([new $v["class"], $v["name"]]);
				$notice = $result ? "\033[32m 测试通过 \033[0m" : "\033[31m 结果异常 \033[0m";
				$notice = is_string($result) ? "\033[31m {$result} \033[0m" : $notice;
			} catch (\Exception $e) {
				$notice = "\033[31m {$e->getMessage()} \033[0m";
			}
			$this->printf("%s %s -> %s:%d %s %s", $notice, $v["name"], basename($v["file"]), $v["line"], $v["doc"]["function_desc"], $v["doc"]["author"]);
		}
	}
}