<?php


use Phinx\Migration\AbstractMigration;

class ModifyThinkNode extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `think_node` modify column `name` varchar(30) NOT NULL;";
        $this->execute($sql);
    }
}
