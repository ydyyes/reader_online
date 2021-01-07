<?php


use Phinx\Migration\AbstractMigration;

class InitXsNovels extends AbstractMigration
{
    /**
     * Change Method.
     *
     * Write your reversible migrations using this method.
     *
     * More information on writing migrations is available here:
     * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
     *
     * The following commands can be used in this method and Phinx will
     * automatically reverse them when rolling back:
     *
     *    createTable
     *    renameTable
     *    addColumn
     *    renameColumn
     *    addIndex
     *    addForeignKey
     *
     * Remember to call "create()" or "update()" and NOT "save()" when working
     * with the Table class.
     */
    public function change()
    {
        $sql = <<<EEE
DROP TABLE IF EXISTS `xs_novels`;
CREATE TABLE `xs_novels` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `_id` char(32) NOT NULL COMMENT 'title的md5或导入的_id,不允许修改',
  `title` varchar(100) NOT NULL COMMENT 'title',
  `author` varchar(200) NOT NULL COMMENT 'author',
  `longIntro` varchar(5000) NOT NULL COMMENT 'longIntro',
  `majorCate` varchar(20) NOT NULL DEFAULT '' COMMENT '分类；默认0，按目前现有分类',
  `minorCate` varchar(20) NOT NULL DEFAULT '' COMMENT '分类；默认0，按目前现有分类',
  `cover` varchar(200) NOT NULL COMMENT '封面',
  `score` decimal(10,1) NOT NULL DEFAULT '0.0' COMMENT 'score',
  `count` int(10) NOT NULL DEFAULT '0' COMMENT '评价人数，默认0',
  `isEffect` tinyint(3) NOT NULL DEFAULT '0' COMMENT '无说明；默认0/false',
  `contentType` varchar(10) NOT NULL DEFAULT 'txt' COMMENT '文件格式；默认txt',
  `buytype` tinyint(3) NOT NULL DEFAULT '0' COMMENT '购买类型；默认0',
  `hasCopyright` tinyint(3) NOT NULL DEFAULT '0' COMMENT '无说明；默认0/false',
  `allowMonthly` tinyint(3) NOT NULL DEFAULT '1' COMMENT '是否包月，默认是',
  `latelyFollower` int(10) NOT NULL DEFAULT '0' COMMENT '阅读的人总数，默认0',
  `wordCount` int(10) NOT NULL DEFAULT '0' COMMENT '总字数，默认0',
  `serializeWordCount` int(10) NOT NULL DEFAULT '0' COMMENT '日更新字数；默认0',
  `retentionRatio` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '留存率；默认0.00',
  `isSerial` tinyint(3) NOT NULL DEFAULT '0' COMMENT '系列；1 系列，0 非系列；默认0',
  `updated` int(10) NOT NULL DEFAULT '0' COMMENT '最后一章节更新时间；默认0',
  `chaptersCount` int(10) NOT NULL DEFAULT '0' COMMENT '总章节；默认0',
  `realchaptersCount` int(10) NOT NULL DEFAULT '0' COMMENT '真实总章节，默认0',
  `lastChapter` varchar(100) NOT NULL DEFAULT '0' COMMENT '最后一章；默认0',
  `gender` varchar(30) NOT NULL DEFAULT '0' COMMENT '类别；默认空',
  `tags` varchar(100) NOT NULL DEFAULT '' COMMENT 'tags；默认空',
  `cat` varchar(30) NOT NULL DEFAULT '' COMMENT '全分类；默认0，目前无信息',
  `openlevel` tinyint(3) NOT NULL DEFAULT '1' COMMENT '一到三 控制尺度 数值越大 尺度越大;因此后台原型等级调整为：3：严重，2：一般，1：擦边；默认选1',
  `type` varchar(50) NOT NULL DEFAULT 'new' COMMENT '参数值 hot new reputation over,对应 新书 热门 口碑 完结 默认new',
  `isfree` tinyint(2) NOT NULL DEFAULT '1' COMMENT '是否免费 1免费 0不是',
  `over` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否完结；0 连载 1完结；默认：1/完结',
  `copyright` varchar(50) NOT NULL DEFAULT '' COMMENT '小说来源；默认空',
  `create_at` int(10) NOT NULL DEFAULT '0',
  `weight` int(10) DEFAULT '0',
  `update_at` int(10) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `isPayChapter` int(10) DEFAULT '0',
  `pathChapters` varchar(200) NOT NULL DEFAULT '' COMMENT '章节索引位置',
  `comment_real` tinyint(1) DEFAULT '1' COMMENT '评论是否真实 1 真实 0 否',
  PRIMARY KEY (`id`),
  UNIQUE KEY `_id` (`_id`),
  KEY `bookId_over` (`_id`,`over`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);

    }
}
