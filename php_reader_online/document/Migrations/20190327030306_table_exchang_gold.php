<?php


use Phinx\Migration\AbstractMigration;

class TableExchangGold extends AbstractMigration
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
CREATE TABLE `xs_exchange_gold` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `type` tinyint(3) NOT NULL,
  `num` int(10) NOT NULL DEFAULT '0',
  `cost_gold` int(10) NOT NULL DEFAULT '1',
  `describe` varchar(400) DEFAULT '',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` int(10) NOT NULL DEFAULT '0',
  `update_time` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
EOL;
        $this->execute($sql);

    }
}
