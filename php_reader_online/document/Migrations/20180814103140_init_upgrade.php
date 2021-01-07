<?php


use Phinx\Migration\AbstractMigration;

class InitUpgrade extends AbstractMigration
{
    public function up()
    {
        $sql = <<<EEE
    create table if not exists `xs_upgrade` (
    `id` int(10) unsigned not null auto_increment,
    `md5` char(32) not null comment 'md5',
    `version` int(10) unsigned not null default 0 comment 'version',
    `apk_url` varchar(100) not null default '' comment 'apk url',
    `chn_id` varchar(200) not null default '' comment 'channel ids',
    `target_size` varchar(20) not null default '0' comment 'target_size',
    `update_log` varchar(200) not null default '' comment 'update_log',
    `status` tinyint(1) NOT NULL DEFAULT 1,
    `create_at` int(10) not null default 0 comment 'create_at',
    `update_at` int(10) not null default 0 comment 'update_at',
    PRIMARY KEY (`id`),
    UNIQUE KEY `md5` (`md5`) USING BTREE 
    )ENGINE=INNODB DEFAULT CHARSET=UTF8;
EEE;
        $this->execute($sql);
    }
}
