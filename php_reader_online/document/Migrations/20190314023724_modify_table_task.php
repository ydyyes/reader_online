<?php


use Phinx\Migration\AbstractMigration;

class ModifyTableTask extends AbstractMigration
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
ALTER TABLE `xs_task` 
ADD COLUMN `task_type` smallint(6) NULL DEFAULT NULL COMMENT '任务类型' AFTER `type`,
ADD INDEX `task_type`(`task_type`) USING HASH;
EOL;
        $this->execute($sql);


    }
}
