<?php
return array(
    'CDN_URL'	=>array(
        'PUBLIC'	=> [
            'DEFAULT' => 'http://'.$_SERVER['HTTP_HOST'].'/static/',
        ],
        'ATTACH'	=>[
            'DEFAULT' => 'http://'.$_SERVER['HTTP_HOST'].'/Uploads/',   #默认
            'STATIC' => 'http://'.$_SERVER['HTTP_HOST'].'/Uploads/',    #指定图片
            'SECOND'  => 'http://7.rt.apiv7.com/gp/ksoffer/',           #次要
            'STATIC_SEC' => 'http://7.rt.apiv7.com/gp/ksoffer/',        #次要图片
        ]
    ),
	'UPLOAD_PATH'	=>array(
			'FILE_PATH_DIR' => ATTACH_PATH,          		//应用文件存放路径，保留反斜杠
			'FILE_PATH_URL' => '/Data/Uploads/',			//应用文件访问URL，保留反斜杠
	),
    'URL_ROUTER_ON'   => true, //开启路由



);
