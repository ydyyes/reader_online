<?php


use Phinx\Migration\AbstractMigration;

class AddSta extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_statistic_chapters` drop index `nid_serial`, modify column `nid` int(10) NOT NULL DEFAULT 0 COMMENT 'nid', modify column `serial` int(10) NOT NULL DEFAULT 0 COMMENT 'serial', add column `center` tinyint(3) NOT NULL DEFAULT 0 COMMENT 'center' after `serial`;";
        $this->execute($sql);
    }
}
