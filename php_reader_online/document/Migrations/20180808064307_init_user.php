<?php


use Phinx\Migration\AbstractMigration;

class InitUser extends AbstractMigration
{
    public function up()
    {
        $sql = <<<EEE
CREATE TABLE `xs_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uni_id` varchar(40) NOT NULL COMMENT '独一无二的ID',
  `devid` varchar(40) NOT NULL COMMENT 'device id=uuid',
  `username` varchar(40) NOT NULL DEFAULT '' COMMENT 'username',
  `mobile` varchar(20) DEFAULT '',
  `nickname` varchar(30) NOT NULL DEFAULT '',
  `vcode` varchar(30) DEFAULT '' COMMENT 'apk的版本号',
  `model` varchar(30) DEFAULT '' COMMENT '设备型号',
  `channel` varchar(30) DEFAULT '' COMMENT '渠道',
  `utid` tinyint(3) NOT NULL DEFAULT '1' COMMENT '1:游客 2: 普通用户 3:会员',
  `gold` int(10) NOT NULL DEFAULT '0',
  `expire` int(10) NOT NULL DEFAULT '0' COMMENT '过期时间',
  `cost` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'cost',
  `create_at` int(10) NOT NULL DEFAULT '0' COMMENT 'create_at',
  `mark` varchar(50) NOT NULL DEFAULT '' COMMENT 'mark',
  `status` tinyint(3) NOT NULL DEFAULT '1' COMMENT 'status',
  `gamecoin` int(10) NOT NULL DEFAULT '0' COMMENT 'golden coin',
  `giftcoin` int(10) NOT NULL DEFAULT '0' COMMENT 'gift',
  `guser` char(32) NOT NULL DEFAULT '' COMMENT 'game username',
  `create_time` int(10) unsigned NOT NULL DEFAULT '0',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  `lock` tinyint(3) NOT NULL DEFAULT '0' COMMENT 'lock gamecoin',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqid` (`uni_id`) USING HASH,
  KEY `mobile` (`mobile`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

    create table if not exists `xs_user_paid_log` (
    `id` int(10) unsigned not null auto_increment,
    `uid` int(10) unsigned not null comment 'user id',
    `days` int(10) not null comment 'days',
    `pay_or` varchar(30) NOT NULL COMMENT 'pay order',
    `pay_h5_or` varchar(50) NOT NULL COMMENT 'pay platform num',
    `pay_bk_or` varchar(50) NOT NULL COMMENT 'pay bank num',
    `pay_by` tinyint(3) NOT NULL COMMENT 'pay by：1 微信；2 支付宝',
    `pay` int(10) NOT NULL DEFAULT '0' COMMENT 'pay',
    `fee` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '手续费',
    `rest` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '剩余金额',
    `pay_time` int(10) NOT NULL DEFAULT '0' COMMENT '支付平台交易时间',
    `status` tinyint(1) NOT NULL DEFAULT '1',
    `create_at` int(10) not null default 0 comment 'create_at',
    PRIMARY KEY (`id`),
    UNIQUE KEY `pay_or` (`pay_or`)
    )ENGINE=INNODB DEFAULT CHARSET=utf8;    
EEE;
        $this->execute($sql);
    }
}
