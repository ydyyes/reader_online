<?php
return array(
		'MODULE_ALLOW_LIST'					=>['Admin', 'Cli', 'Test','Pay','Api','Apin','Vend'],
		'DEFAULT_MODULE'					=>'Admin',
		'APP_SUB_DOMAIN_DEPLOY'				=>1,
		'APP_SUB_DOMAIN_SUFFIX'				=>APP_HOST_FIX,
		'APP_SUB_DOMAIN_RULES'				=>array(
				'admin'			=>array('Admin'),
				'api'			=>array('Api'),
				'test'			=>array('Test'),
		),
);
