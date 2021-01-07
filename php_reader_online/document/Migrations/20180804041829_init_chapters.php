<?php


use Phinx\Migration\AbstractMigration;

class InitChapters extends AbstractMigration
{
    public function up()
    {
        $sql = <<<EEE
CREATE TABLE IF NOT EXISTS `xs_chapters` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nid` int(10) NOT NULL COMMENT 'novel id',
  `chid` char(32) NOT NULL COMMENT 'chapter md5',
  `serial` int(10) NOT NULL DEFAULT 1 COMMENT '第n章',
  `title` varchar(100) NOT NULL COMMENT 'title',
  `link` varchar(100) NOT NULL COMMENT 'link',
  `create_at` int(10) NOT NULL DEFAULT '0',
  `update_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nid_chid` (`nid`,`chid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
