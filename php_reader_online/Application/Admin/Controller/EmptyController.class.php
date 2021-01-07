<?php
namespace Admin\Controller;
use Think\Controller;

class EmptyController extends Controller
{
	function _empty($param_arr)
	{
		//控制器进行分层处理
		$controllers = explode("_", parse_name(CONTROLLER_NAME));
		if(count($controllers) >= 1 && is_dir(__DIR__.DIRECTORY_SEPARATOR.ucfirst($controllers[0])))
		{
			$controller = sprintf("%s\\%s\\%s%s", __NAMESPACE__, ucfirst($controllers[0]), CONTROLLER_NAME, C('DEFAULT_C_LAYER'));
			$controller_instance = new $controller();
			
			$action = ACTION_NAME;
			$class  = new \ReflectionClass($controller);
			
			// 前置操作
			if($class->hasMethod('_before_'.$action)) {
				$before =   $class->getMethod('_before_'.$action);
				if($before->isPublic())
					$before->invoke($controller_instance);
			}

			try {
				$methodInfo = new \ReflectionMethod($controller, $action);
				if ($methodInfo->isPublic() && !$methodInfo->isStatic()) {
					$methodInfo->invoke($controller_instance);
				} else {
					throw new \ReflectionException();
				}
			} catch (\ReflectionException $e) {
				// 方法调用发生异常后，引导到__call方法处理
				$methodInfo = new \ReflectionMethod($controller, '__call');
				$methodInfo->invokeArgs($controller_instance, array($action, ''));
			}
			
			// 后置操作
			if($class->hasMethod('_after_'.$action)) {
				$after =   $class->getMethod('_after_'.$action);
				if($after->isPublic())
					$after->invoke($controller_instance);
			}
			return;
		}
		
		try {
			$this->display();
		} catch (\Exception $e) {
			if(APP_DEBUG)
				throw_exception('[空操作]'.$e->getMessage());
			else
				\Think\Think::halt('非法操作了噻');
		}
	}
}
