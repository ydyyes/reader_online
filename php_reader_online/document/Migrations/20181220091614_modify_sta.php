<?php


use Phinx\Migration\AbstractMigration;

class ModifySta extends AbstractMigration
{
    public function change()
    {
        $this->execute("alter table `xs_statistic_keywords` modify column `keyword` varchar(200) NOT NULL COMMENT 'keyword'");
    }
}
