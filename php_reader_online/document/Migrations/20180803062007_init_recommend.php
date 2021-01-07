<?php


use Phinx\Migration\AbstractMigration;

class InitRecommend extends AbstractMigration
{
    public function up()
    {
        $sql = <<<EEE
CREATE TABLE IF NOT EXISTS `xs_recommend` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nid` int(10) NOT NULL COMMENT 'novel_id',
  `rating` int(10) unsigned NOT NULL DEFAULT 0,
  `chn_id` varchar(200) NOT NULL COMMENT 'channel ids', 
  `chn_v_ids` varchar(300) NOT NULL default '' comment 'channel-version',
  `create_at` int(10) NOT NULL DEFAULT 0,
  `update_at` int(10) NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
