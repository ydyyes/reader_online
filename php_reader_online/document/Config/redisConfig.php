<?php
/**
 * author:liu.
 */

$config['rediscache']['instance1'] = array(
    'default' => array(
            'host' => '127.0.0.1',
            'port' => '6383',
            'timeout' => 5,
            'password'=>'',
            'pconnect' => 1,
    )
);
//$config['rediscache']['instance2'] = array(
//    'default' => array(
//        'host' => '127.0.0.1',
//        'port' => '6382',
//        'timeout' => 5,
//        'password'=>'123456',
//        'pconnect' => 1,
//    )
//);

return $config;