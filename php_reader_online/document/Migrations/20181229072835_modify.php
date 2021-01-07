<?php


use Phinx\Migration\AbstractMigration;

class Modify extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_statistic_keywords` add Column `day` int(10) NOT NULL DEFAULT 0 COMMENT 'day: 20180101'; alter table `xs_statistic_keywords` add index `day` (`day`);";
        $sql .= "alter table `xs_statistic_readtimes` add Column `day` int(10) NOT NULL DEFAULT 0 COMMENT 'day: 20180101';alter table `xs_statistic_readtimes` add index `day` (`day`), drop index `nid`, add index `nid` (`nid`);";
        $this->execute($sql);
    }
}
