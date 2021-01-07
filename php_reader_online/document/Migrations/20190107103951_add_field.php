<?php


use Phinx\Migration\AbstractMigration;

class AddField extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_statistic_chapters` add Column `fade_persons` int(10) NOT NULL DEFAULT 0 COMMENT 'fade_persons';";
        $this->execute($sql);
    }
}
