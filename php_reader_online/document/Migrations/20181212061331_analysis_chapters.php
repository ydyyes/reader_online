<?php


use Phinx\Migration\AbstractMigration;

class AnalysisChapters extends AbstractMigration
{
    public function change()
    {
        $sql = <<<EEE
CREATE TABLE IF NOT EXISTS `xs_statistic_chapters` (
  `id` int(10) NOT NULL auto_increment,
  `nid` int(10) NOT NULL COMMENT 'novel id',
  `chid` char(32) NOT NULL COMMENT 'chapter md5',
  `persons` int(10) NOT NULL DEFAULT 0 COMMENT '付费总人次',
  `persons_mon` int(10) NOT NULL DEFAULT 0 COMMENT '包月人次',
  `persons_hy` int(10) NOT NULL DEFAULT 0 COMMENT '半年人次',
  `persons_y` int(10) NOT NULL DEFAULT 0 COMMENT '半年人次',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `xs_statistic_keywords` (
  `id` int(10) NOT NULL auto_increment,
  `keyword` int(10) NOT NULL COMMENT 'keyword',
  `count` int(10) NOT NULL DEFAULT 0 COMMENT '累计量',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `xs_statistic_readtimes` (
  `id` int(10) NOT NULL auto_increment,
  `nid` int(10) NOT NULL COMMENT 'novel id',
  `count` int(10) NOT NULL DEFAULT 0 COMMENT '阅读量',
  `count_shelf` int(10) NOT NULL DEFAULT 0 COMMENT '加入书架量',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `xs_statistic_dloadtimes` (
  `id` int(10) NOT NULL auto_increment,
  `nid` int(10) NOT NULL COMMENT 'novel id',
  `count` int(10) NOT NULL DEFAULT 0 COMMENT '下载量',
  `chn_id` int(10) NOT NULL COMMENT '渠道id',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
