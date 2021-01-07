<?php
/**
 * 导入后台可调整的配置项
 * $memu = [
 *		"参数名"	=>["参数说明", "默认值", array("option"=>"", "type"=>"")],
 * ]
 * 
 * 执行 php cli.php menu/make 进行同步
 * 
 * 获取配置
 * D("SysConfig")->getValue('SOME_CONF');
 */
$config = [
		"SYSTEM_IS_OFFLINE"				=>["系统下线，禁止访问", 0, ["type"=>"radio", "option"=>'{"1":"下线","0":"上线"}'], ],
];

return $config;
