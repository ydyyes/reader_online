<?php


use Phinx\Migration\AbstractMigration;

class AddToken extends AbstractMigration
{
    public function up()
    {

        $sql = <<<SSS
        CREATE TABLE `xs_games` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT 'name',
  `img` varchar(200) NOT NULL COMMENT 'image',
  `link` varchar(200) NOT NULL COMMENT 'url',
  `create_at` int(10) NOT NULL DEFAULT '0',
  `update_at` int(10) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SSS;
        $this->execute($sql);
    }
}
