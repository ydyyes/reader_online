<?php


use Phinx\Migration\AbstractMigration;

class AddNovelCates extends AbstractMigration
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
ALTER TABLE  `xs_novels` 
ADD COLUMN `maCate` smallint(6) NOT NULL DEFAULT 0 COMMENT '0' AFTER `minorCate`,
ADD COLUMN `minCate` smallint(6) NOT NULL DEFAULT 0 COMMENT '0' AFTER `maCate`;
EEE;
        $this->execute($sql);

    }
}
