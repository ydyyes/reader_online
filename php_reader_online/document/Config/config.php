<?php
/**
 * 全局配置文件
 * 该配置文件为配置文件的入口文件，只用来导入其它扩展配置文件，非 debug 模式下会编译到 runtime 中
 * @link http://doc.thinkphp.cn/manual/extend_config.html
 */
return array(
		'LOAD_EXT_CONFIG' => array(
            'cookie',
            'database',
            'email',
            'migrate',
            'module',
            'system',
            'url',
            'config',
            'sms',
            'game',
            'redisConfig',
            'route',
            'pay'
		),
		'DEFAULT_MODULE' =>'Admin',
        'AES_KEY'        =>'J4gtW7Pbw1Xuxarq',
        //生产模式开启这个配置,防止泄露
        'TMPL_EXCEPTION_FILE'     =>APP_PATH.'Common'.DIRECTORY_SEPARATOR.'Tpl'.DIRECTORY_SEPARATOR.'exception.php',
        'REDIS_SIGN_TIME' => 20,
        'SIGN_TIME'       =>10,
        'F_CDN'           => 'http://dwtxt.xs8.ltd/',
        'IP_AC'          => 'http://192.168.232.245/',
        'MAX_PAGE_SIZE'   =>20,
        'WEB_P_CODE'      =>'SPasdasD332z@44S!22',
        'WEB_UUID'        =>'WEBASASQdasdSES2ED',
        'dev_server_secret' => '563a13081ae56dd7'



);
