<?php
namespace Cli\Controller;

use Think\Controller;
use Think\Log;

class ClibaseController extends Controller
{
    function _initialize()
    {
    	set_time_limit(0);
    	ini_set('memory_limit', '-1');
    	
    	if(PHP_SAPI !== 'cli')
    	{
    		header('Location: '.U("@www"));
    		exit;
    	}
    	
        if (method_exists($this, '_init'))
        {
            $this->_init();
        }
    }

    protected function clear($out = TRUE)
    {
    	$clearscreen = chr ( 27 ) . "[H" . chr ( 27 ) . "[2J";
    	if ($out)
    		print $clearscreen;
    	else
    		return $clearscreen;
    }
    
    function printf()
    {
    	$args = func_get_args();
    	if(count($args) == 1){
    		$msg = $args[0].PHP_EOL;
    	}else{
    		$args[0] = $args[0].PHP_EOL;
    		$msg = call_user_func_array("sprintf", $args);
    	}

    	echo $msg;
    	Log::write(trim($msg), Log::EMERG);
    }
    
    /**
     * 通过反射获取类的相关信息
     * @param class $class
     * @return Array
     */
    protected function getClassAnnotation($class)
    {
    	return array(
    			'name'		=> $class->getName (),
    			'class'		=> array(
    					'parentClass'	=> $class->getParentClass()->name,
    					'fileName'		=> $class->getFileName(),
    					'startLine'		=> $class->getStartLine(),
    					'endLine'		=> $class->getEndLine(),
    			),
    			'comment'	=> self::parseAnnotations($class->getDocComment()),
    	);
    }
    
    /**
     * 格式化函数和类的注释
     * @author shuhai
     * @param string $docblock
     * @return Array
     */
    protected function parseAnnotations($docblock)
    {
    	$annotations = array();
    	$docblock = substr($docblock, 3, -2);
    
    	//格式化说明
    	$desc = preg_split("/\s*?@/is", $docblock);
    	$desc = array_shift($desc);
    	$desc = preg_replace("@\s*?\*\s*?@is", PHP_EOL, $desc);
    	$annotations["function_desc"] = trim($desc);
    
    	//格式化属性
    	if (preg_match_all('/@(?<name>[A-Za-z_-]+)[\s\t]*\(?(?<args>.*)\)?[\s\t]*\r?$/m', $docblock, $matches))
    	{
    		$numMatches = count($matches[0]);
    		for ($i = 0; $i < $numMatches; ++$i) {
    			if (isset($matches['args'][$i])) {
    				$argsParts = trim($matches['args'][$i]);
    				$name      = $matches['name'][$i];
    				$value     = $argsParts;
    				$annotations[$name] = $value;
    			}
    		}
    	}
    	return $annotations;
    }
}