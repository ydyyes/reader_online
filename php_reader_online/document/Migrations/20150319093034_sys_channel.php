<?php

use Phinx\Migration\AbstractMigration;

class Syschannel extends AbstractMigration
{
    public function up()
    {
    	$sql = <<<EEE
SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `sys_channel`
-- ----------------------------
DROP TABLE IF EXISTS `sys_channel`;
CREATE TABLE `sys_channel` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `cname` varchar(200) NOT NULL DEFAULT '',
  `hash` varchar(10) NOT NULL DEFAULT '' COMMENT 'hash code',
  `mark` varchar(200) NOT NULL DEFAULT '',
  `create_at` int(10) NOT NULL,
  `admin_id` int(10) NOT NULL DEFAULT '0' COMMENT '添加渠道的管理员',
  `status` int(1) NOT NULL DEFAULT '0',
  `channel_admin_id` int(10) NOT NULL DEFAULT '0' COMMENT '渠道管理员',
  `type` int(1) NOT NULL DEFAULT '2' COMMENT '类型：1表示CP, 2表示渠道',
  `ratio_sharing` decimal(10,2) NOT NULL DEFAULT '100.00' COMMENT '渠道分成百分比',
  `ratio_show` decimal(10,2) NOT NULL DEFAULT '100.00' COMMENT '百分比',
  `ratio_click` decimal(10,2) NOT NULL DEFAULT '100.00' COMMENT '百分比',
  PRIMARY KEY (`id`,`name`),
  UNIQUE KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `sys_version`
-- ----------------------------
DROP TABLE IF EXISTS `sys_version`;
CREATE TABLE `sys_version` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `version_name` varchar(120) NOT NULL DEFAULT '' COMMENT '版本名称',
  `version_code` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '版本号',
  `create_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '记录创建时间',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建者id',
  PRIMARY KEY (`id`),
  KEY `version_code` (`version_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `sys_version_channel`
-- ----------------------------
DROP TABLE IF EXISTS `sys_version_channel`;
CREATE TABLE `sys_version_channel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `channel_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '渠道id',
  `version_id` int(10) NOT NULL DEFAULT '0' COMMENT '最后更新应用的记录id',
  `create_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '记录创建时间',
  `create_admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建者id',
  `version_code` int(10) NOT NULL COMMENT '应用版本号',
  `status` int(1) unsigned NOT NULL DEFAULT '1' COMMENT '该渠道下的此版本是否启用 0:禁用 1:启用',
  PRIMARY KEY (`id`),
  KEY `channel_id` (`channel_id`) USING BTREE,
  KEY `version_id` (`version_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `sys_channel_admin`
-- ----------------------------
DROP TABLE IF EXISTS `sys_channel_admin`;
CREATE TABLE `sys_channel_admin` (
  `channel_id` smallint(6) unsigned NOT NULL COMMENT '角色',
  `admin_id` smallint(6) unsigned NOT NULL COMMENT '节点',
  `administrator` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否为渠道超级管理员',
  KEY `groupId` (`channel_id`),
  KEY `nodeId` (`admin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='qudo角色关系表';
EEE;
    	$this->query($sql);
    }
    
    public function down()
    {
		$tables = "sys_channel,sys_version,sys_version_channel,sys_channel_admin";
		$tables = explode(",", $tables);
		foreach ($tables as $table)
			$this->dropTable($table);
    }
}