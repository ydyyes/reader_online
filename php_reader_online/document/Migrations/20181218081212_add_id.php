<?php


use Phinx\Migration\AbstractMigration;

class AddId extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_chapters` add column `_id` char(32) NOT NULL COMMENT '_id' after `nid`;";
        $this->execute($sql);
    }
}
