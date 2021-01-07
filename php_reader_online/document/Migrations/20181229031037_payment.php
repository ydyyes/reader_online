<?php


use Phinx\Migration\AbstractMigration;

class Payment extends AbstractMigration
{
    public function change()
    {
        $sql = <<<EEE
        CREATE TABLE `xs_statistic_payment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `channel` varchar(50) NOT NULL DEFAULT '' COMMENT 'channel name',
  `persons` int(10) NOT NULL DEFAULT '0' COMMENT '付费总人次',
  `persons_mon` int(10) NOT NULL DEFAULT '0' COMMENT '包月人次',
  `persons_hy` int(10) NOT NULL DEFAULT '0' COMMENT '半年人次',
  `persons_y` int(10) NOT NULL DEFAULT '0' COMMENT '半年人次',
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '金额',
  `day` int(10) NOT NULL DEFAULT '0' COMMENT 'day：20180101',
  PRIMARY KEY (`id`),
  UNIQUE KEY `channel_day` (`channel`, `day`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EEE;
        $sql .= "alter table `xs_user_paid_log` add column `channel` varchar(50) NOT NULL DEFAULT '' after `days`;";
        $this->execute($sql);
    }
}
