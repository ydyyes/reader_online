<?php


use Phinx\Migration\AbstractMigration;

class AddTaskLogType extends AbstractMigration
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
        $sql =<<<EOF
ALTER TABLE `xs_task_log` 
ADD COLUMN `type` tinyint(3) NOT NULL DEFAULT 1 COMMENT '对应的奖励类型' AFTER `tid`,
ADD COLUMN `num` int(10) NOT NULL DEFAULT 0 COMMENT '对应的数量' AFTER `type`;
EOF;
 $this->execute($sql);

    }
}
