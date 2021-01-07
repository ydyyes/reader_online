<?php


use Phinx\Migration\AbstractMigration;

class CoinLog extends AbstractMigration
{
    public function change()
    {
        $sql = <<<EEE
        CREATE TABLE `xs_coin_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL COMMENT 'user id',
  `orno` varchar(20) NOT NULL COMMENT 'order',
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单金额',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `type` tinyint(3) NOT NULL COMMENT '1 充值；2 提现',
  `create_at` int(10) NOT NULL DEFAULT '0' COMMENT 'create_at',
  `update_at` int(10) NOT NULL DEFAULT '0' COMMENT 'update_at',
  PRIMARY KEY (`id`),
  UNIQUE KEY `orno` (`orno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
