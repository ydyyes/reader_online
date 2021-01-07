<?php


use Phinx\Migration\AbstractMigration;

class TableGoldLog extends AbstractMigration
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
        $sql = <<<EOL
  CREATE TABLE `xs_gold_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '金币明细的名称',
  `eid` int(10) NULL DEFAULT 0 COMMENT '兑换表ID',
  `etype` smallint(5) NULL DEFAULT 0 COMMENT '兑换表类型',
  `describe` varchar(150) NOT NULL DEFAULT '' COMMENT '描述',
  `num` int(10) NOT NULL DEFAULT '0' COMMENT '数量',
  `create_time` int(10) DEFAULT NULL,
    INDEX `uid`(`uid`,`create_time`) USING BTREE,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
EOL;
        $this->execute($sql);


    }
}
