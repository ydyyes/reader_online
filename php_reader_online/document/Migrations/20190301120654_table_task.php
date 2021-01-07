<?php


use Phinx\Migration\AbstractMigration;

class TableTask extends AbstractMigration
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
DROP TABLE IF EXISTS `xs_task`;
CREATE TABLE `xs_task` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '任务名称',
  `describe` varchar(200) DEFAULT '',
  `type` tinyint(3) DEFAULT '1' COMMENT '奖励类型 1 会员天数 2 金币',
  `way` tinyint(1) DEFAULT '1' COMMENT '奖励方式 1 固定 2 随机',
  `num` int(10) DEFAULT '0' COMMENT '如果way为2 是取值范围',
  `status` tinyint(1) DEFAULT '1' COMMENT '1 上架 0 下架',
  `create_time` int(10) DEFAULT '0',
  `update_time` int(10) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `xs_task_log`
-- ----------------------------
DROP TABLE IF EXISTS `xs_task_log`;
CREATE TABLE `xs_task_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) NOT NULL,
  `tid` int(10) NOT NULL COMMENT '任务id',
  `channel` varchar(30) NOT NULL DEFAULT '',
  `create_time` int(10) NOT NULL,
  `update_time` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);

    }
}
