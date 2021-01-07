<?php
/* 系统发送邮件邮箱设置 */
return array(
	'SMTP' => array(
		'SMTP_HOST'				=>'smtp.mxhichina.com',			//smtp服务器
		'SMTP_PORT'				=>25,						//smtp端口
		'SMTP_MAIL'				=>'sendmail@whaledigit.com',	    //SMTP服务器的用户邮箱
		'SMTP_USER'				=>'sendmail@whaledigit.com',	    //SMTP服务器的用户
		'SMTP_PASSWORD'			=>'Ks123.4567',		//密码
		'SMTP_NAME'				=>'蓝鲸数码',	//在邮件中显示发件人名称
		'SMTP_FROM'				=>'sendmail@whaledigit.com',		//在邮件中显示发件人来源
	),
    'NOTICE' => array(
        'GENERAL'   => 'test@whaledigit.com',
    ),
);