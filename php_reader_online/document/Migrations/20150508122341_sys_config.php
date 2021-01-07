<?php

use Phinx\Migration\AbstractMigration;

class SysConfig extends AbstractMigration
{
	function up()
	{
		$sql = <<<EEE
		CREATE TABLE `sys_config` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '',
  `type` varchar(100) NOT NULL DEFAULT '',
  `option` varchar(1000) NOT NULL DEFAULT '',
  `value` varchar(500) NOT NULL DEFAULT '',
  `comment` varchar(500) NOT NULL DEFAULT '',
  `tpl` varchar(500) NOT NULL DEFAULT '',
  `validate_type` varchar(100) NOT NULL DEFAULT '',
  `delfault` varchar(500) NOT NULL DEFAULT '',
  `create_at` int(10) NOT NULL DEFAULT '0',
  `update_at` int(10) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EEE;
		
		$this->query($sql);
	}	
}