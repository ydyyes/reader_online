<?php
/**
 * RBAC 安装器
 * @author shuhai
 * @uses   php vendor/bin/phinx migrate -c Data/Config/migrate.php
 */
use Phinx\Migration\AbstractMigration;

class InitappMigration extends AbstractMigration
{
    public function up()
    {
    	$sql = <<<EEE
DROP TABLE IF EXISTS `think_access`;
CREATE TABLE IF NOT EXISTS `think_access` (
  `role_id` smallint(6) unsigned NOT NULL,
  `node_id` smallint(6) unsigned NOT NULL,
  `level` tinyint(1) NOT NULL DEFAULT '0',
  `module` varchar(50) DEFAULT NULL,
  `pid` smallint(6) DEFAULT '0',
  KEY `groupId` (`role_id`),
  KEY `nodeId` (`node_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `think_node`;
CREATE TABLE `think_node` (
  `id` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `params` varchar(250) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  `sort` smallint(6) unsigned DEFAULT '0',
  `pid` smallint(6) unsigned NOT NULL DEFAULT '0',
  `level` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `type` tinyint(1) NOT NULL DEFAULT '0',
  `group_id` tinyint(3) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `level` (`level`),
  KEY `pid` (`pid`),
  KEY `status` (`status`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `think_role`;
CREATE TABLE IF NOT EXISTS `think_role` (
  `id` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `pid` smallint(6) DEFAULT NULL,
  `status` tinyint(1) unsigned DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pid` (`pid`),
  KEY `status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `think_role_user`;
CREATE TABLE IF NOT EXISTS `think_role_user` (
  `role_id` mediumint(9) unsigned DEFAULT NULL,
  `user_id` char(32) DEFAULT NULL,
  KEY `group_id` (`role_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `think_admin`;
CREATE TABLE `think_admin` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `account` varchar(64) DEFAULT NULL COMMENT '管理员登陆名',
  `nickname` varchar(50) DEFAULT NULL,
  `password` char(32) DEFAULT NULL,
  `bind_account` varchar(50) DEFAULT NULL,
  `last_login_time` int(11) unsigned DEFAULT '0',
  `last_login_ip` varchar(40) DEFAULT NULL,
  `login_count` mediumint(8) unsigned DEFAULT '0',
  `verify` varchar(32) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `create_time` int(11) unsigned DEFAULT '0',
  `update_time` int(11) unsigned DEFAULT '0',
  `status` tinyint(1) DEFAULT '0' COMMENT '1 账号启用 0 未启用',
  `agent_id` tinyint(5) unsigned DEFAULT '0',
  `info` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account` (`account`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `think_node_group`;
CREATE TABLE `think_node_group` (
  `id` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `status` tinyint(1) unsigned zerofill NOT NULL DEFAULT '1',
  `sort` int(5) DEFAULT '0',
  `detail` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `think_admin` (`account`, `nickname`, `password`, `status`) VALUES ('admin', 'admin', md5('admin'), 1);
INSERT INTO `think_node_group` VALUES ('1', '根结点', '1', '0', null), ('2', '系统设置', '1', '100', null);
INSERT INTO `think_node` VALUES 
('1', 'Application', 'Application', 'index', '', '1', '', '2', '0', '1', '0', '1'),
('2', 'Index', '默认模块', 'index', '', '1', '', '0', '1', '2', '0', '1'),
('3', 'Public', '公共模块', 'index', '', '1', '', '0', '1', '2', '0', '1'),
('4', 'NodeGroup', '后台菜单', 'index', '', '1', '', '1004', '1', '2', '0', '2'),
('5', 'AdminUser', '后台用户', 'index', 'numPerPage=30\norderField=id', '1', '', '1001', '1', '2', '0', '2'),
('6', 'Role', '角色管理', 'index', null, '1', '', '1002', '1', '2', '0', '2'),
('7', 'Node', '节点管理', 'index', '', '1', '', '1003', '1', '2', '0', '2');
EEE;
    	$this->execute($sql);
    }
    
    public function down()
    {
		$initTables = ['think_access', 'think_admin', 'think_node', 'think_node_group', 'think_role', 'think_role_user'];
		foreach ($initTables as $table)
			$this->dropTable($table);
		printf("tables %s droped ok\n", join(", ", $initTables));
    }
}