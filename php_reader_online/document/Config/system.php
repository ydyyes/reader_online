<?php
return array(
		/* 链接配置,1,pathinfo;2,rewrite;3,兼容模式 */
		'URL_MODEL'							=>3,
		'URL_HTML_SUFFIX'					=>'.html',
		'URL_CASE_INSENSITIVE'				=>true,

		'SHOW_PAGE_TRACE'					=>APP_DEBUG,
		'TOKEN_ON'							=>false,
		'APP_DEBUG'							=>false,
		'VAR_PAGE'							=>'pageNum',			//分页变量
		'PAGE_LISTROWS'						=>10,					//分页显示数量
		'VAR_FILTERS'						=>'_call_var_filters',
		'DEFAULT_FILTER'					=>'dhtmlspecialchars',
		'VAR_URL_PARAMS'					=>'_URL_',

		/* Cookie设置 */
		'COOKIE_EXPIRE'						=>3600,					// Coodie有效期
		'COOKIE_DOMAIN'						=>".baidu.com",			// Cookie有效域名
		'COOKIE_PATH'						=>'/',					// Cookie路径
		'COOKIE_PREFIX'						=>'cookie_pre',			// Cookie前缀 避免冲突

		/* 模板设置 */
		'DEFAULT_THEME'						=>'default',
		'URL_PARAMS_BIND'					=>false,

		/* SESSION */
		'SESSION_AUTO_START'				=>false,
		'SESSION_OPTIONS'					=>array('path'=>SESSION_PATH),

		/*日志记录*/
		'OUTPUT_ENCODE'						=>false,
		'SHOW_ERROR_MSG'					=>APP_DEBUG,
		'LOG_RECORD'						=>true,
		'LOG_LEVEL'							=>'EMERG,ALERT,CRIT,ERR',

		/* 项目扩展配置 */
		'COMMENT_GLOBAL'					=>array('close'=>false,'interval'=>15),
		'SITE_DEV_DOMAIN'					=>'www.4wei.cn',
		'SITENAME'							=>'管理中心',
		'CONTACT'							=>'admin@4wei.cn',
		'COMPANY'							=>'ThinkPHP',
		'OFFLINE'							=>false,
		'OFFLINEMESSAGE'					=>'本站正在维护中，暂不能访问。<br /> 请稍后再访问本站。',
		'OFFLINEALLOWIP'                    =>'127.0.0.1,1.202.254.38',
		'COPYRIGHT'							=>'www.4wei.cn',
		'DEFAULT_TIMEZONE'					=>'Asia/Shanghai',
		'SERVICE_QQ'						=>'130775',

		/* 关闭注册开关 */
		'CLOSE_REG'							=>FALSE,
);
