<?php


use Phinx\Migration\AbstractMigration;

class ModifyChannelHash extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `sys_channel` modify column `hash` varchar(13) NOT NULL DEFAULT '' COMMENT 'hash code';";
        $this->execute($sql);
    }
}
