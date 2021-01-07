<?php


use Phinx\Migration\AbstractMigration;

class InitCategory extends AbstractMigration
{
    public function up()
    {
        $sql = <<<EEE
CREATE TABLE `xs_cates` (
  `id` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT 'NAME',
  `pid` smallint(5) unsigned NOT NULL DEFAULT '0',
  `name_path` varchar(50) DEFAULT '',
  `level` tinyint(1) NOT NULL DEFAULT '1',
  `create_at` int(10) NOT NULL DEFAULT '0',
  `status` tinyint(2) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`) USING BTREE
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
