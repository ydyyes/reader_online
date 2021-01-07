<?php


use Phinx\Migration\AbstractMigration;

class Carousel extends AbstractMigration
{
    public function change()
    {
        $sql = <<<EEE
        CREATE TABLE `xs_carousel_map` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'name',
  `type` tinyint(3) NOT NULL COMMENT 'type 1:ad 2:book',
  `fid` char(32) NOT NULL DEFAULT '' COMMENT 'foreign table id',
  `img` varchar(100) NOT NULL DEFAULT '' COMMENT 'img url',
  `status` tinyint(3) NOT NULL DEFAULT '1' COMMENT 'status',
  `weight` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `create_at` int(10) NOT NULL DEFAULT '0',
  `update_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
