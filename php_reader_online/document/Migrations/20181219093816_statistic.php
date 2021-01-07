w<?php


use Phinx\Migration\AbstractMigration;

class Statistic extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_statistic_readtimes` add unique key `nid`(`nid`);";
        $sql .= "alter table `xs_statistic_chapters` change column `chid` `serial` int(10) NOT NULL COMMENT '第n章';alter table `xs_statistic_chapters` add unique key `nid_serial`(`nid`, `serial`);";
        $this->execute($sql);
    }
}
