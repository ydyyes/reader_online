<?php


use Phinx\Migration\AbstractMigration;

class ModifyIndex extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_chapters` drop index `nid_chid`;";
        $sql .= "alter table `xs_chapters` add unique key `nid_serial`(`nid`, `serial`);";
        $this->execute($sql);
    }
}
