<?php


use Phinx\Migration\AbstractMigration;

class AddAd extends AbstractMigration
{
    public function change()
    {
        $sql = <<<EEE
CREATE TABLE IF NOT EXISTS `xs_ads` (
  `id` int(10) NOT NULL auto_increment COMMENT '广告id',
  `title` varchar(300) NOT NULL COMMENT '标题',
  `link` varchar(200) NOT NULL DEFAULT '' COMMENT '链接',
  `location` tinyint(3) NOT NULL DEFAULT 1 COMMENT 'ad location;1 开屏; 2 文章末尾',
  `img` varchar(100) NOT NULL COMMENT '封面', 
  `chn_v_ids` varchar(200) NOT NULL DEFAULT '' COMMENT '渠道版本ids',
  `create_at` int(10) NOT NULL DEFAULT 0 COMMENT '添加时间',
  `update_at` int(10) NOT NULL DEFAULT 0 COMMENT '更新时间',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
