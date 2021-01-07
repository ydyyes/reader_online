<?php


use Phinx\Migration\AbstractMigration;

class TableYouMiLog extends AbstractMigration
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
CREATE TABLE `xs_youmi_log` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT ' ',
  `order_id` varchar(50) NOT NULL,
  `uni_id` varchar(40) NOT NULL DEFAULT '',
  `gold` int(10) NOT NULL DEFAULT 0,
  `json_data` text,
  `y_time` int(10) DEFAULT '0',
  `create_time` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_Id` (`order_id`) USING HASH
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

ALTER TABLE `xs_novels` 
MODIFY COLUMN `author` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'author' AFTER `title`,
ADD INDEX `type`(`type`) USING BTREE;
EOL;
        $this->execute($sql);


    }
}
