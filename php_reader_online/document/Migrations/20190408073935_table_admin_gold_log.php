<?php


use Phinx\Migration\AbstractMigration;

class TableAdminGoldLog extends AbstractMigration
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
       CREATE TABLE `xs_admin_gold_log`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `uid` int(10) NULL DEFAULT 0,
  `info` varchar(200) NULL DEFAULT '',
  `operator` varchar(50) NOT NULL DEFAULT '' ,
  `create_time` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);     
EOL;
        $this->execute($sql);


    }
}
