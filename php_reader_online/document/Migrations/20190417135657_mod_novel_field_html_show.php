<?php


use Phinx\Migration\AbstractMigration;

class ModNovelFieldHtmlShow extends AbstractMigration
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
ALTER TABLE  `xs_novels` 
ADD COLUMN `html_show` tinyint(1) NOT NULL default 0 COMMENT 'type控制,是否在h5中展示' AFTER `isPayChapter`;
EOL;

        $this->execute($sql);


    }
}
