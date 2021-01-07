<?php


use Phinx\Migration\AbstractMigration;

class WithdrawOrders extends AbstractMigration
{
    public function change()
    {
        $sql = <<<EEE
        CREATE TABLE `xs_withdraw_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL COMMENT 'user id',
  `gamecoin` int(10) unsigned NOT NULL COMMENT 'gamecoin',
  `alipay` varchar(50) NOT NULL COMMENT 'ali account',
  `aliname` varchar(50) NOT NULL DEFAULT '' COMMENT 'ali name',
  `contact` varchar(50) NOT NULL COMMENT 'contact', 
  `orno` varchar(20) NOT NULL COMMENT 'pay order',
  `pay_ali_or` varchar(40) NOT NULL COMMENT '2018122122001447550529956375',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单金额',
  `receipt_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '实际金额',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `create_at` int(10) NOT NULL DEFAULT '0' COMMENT 'create_at',
  `update_at` int(10) NOT NULL DEFAULT '0' COMMENT 'update_at',
  PRIMARY KEY (`id`),
  UNIQUE KEY `orno` (`orno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
