<?php
/**
 * 全局配置文件
 * 该配置文件为配置文件的入口文件，只用来导入其它扩展配置文件，非 debug 模式下会编译到 runtime 中
 * @link http://doc.thinkphp.cn/manual/extend_config.html
 */
return array(
        /* 数据库配置 */
        'DB_TYPE'                                                       =>'mysql',
        'DB_HOST'                                                       =>'127.0.0.1',
        'DB_NAME'                                                       =>'thinkphp',
        'DB_USER'                                                       =>'root',
        'DB_PWD'                                                        =>'',
        'DB_PORT'                                                       =>'3306',
        'DB_CHARSET'                                                    =>'UTF8',
        'DB_PREFIX'                                                     =>'',
        'DB_PARAMS'                                                     => array(\PDO::ATTR_CASE => \PDO::CASE_NATURAL),

        'SESSION_OPTIONS'                                               =>'true',
        'SESSION_TYPE'                                                  =>'Common\Controller\RedisSession',

        'DATA_CACHE_TYPE'                                               =>'Redis',
        'DATA_CACHE_TIME'                                               =>0,
        'DATA_CACHE_TIMEOUT'                                            =>86400,
        'DATA_CACHE_PREFIX'                                             =>'book_',
        'MEMCACHE_HOST'                                                 =>'localhost',
        'MEMCACHE_PORT'                                                 =>'11211',
        'REDIS_HOST'                                                    =>'localhost',
        'REDIS_PORT'                                                    =>'6379',
        'REDIS_PASSWORD'                                                =>'',
        'REDIS_PREFIX'                                                  =>'book_',
        'EXPORT_DB_PWD'                                                 =>'123456',
        'TOKEN_TIMEOUT'                                                 =>2592000,
        //实际限制为5个
        'TOKEN_LIMIT'                                                   =>5,
        'USER_ADMIN_LOGIN'                                             =>'17600116718',
        'USER_ADMIN_CODE'                                              =>'2897'
);
