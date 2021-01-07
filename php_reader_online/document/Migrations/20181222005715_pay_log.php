<?php


use Phinx\Migration\AbstractMigration;

class PayLog extends AbstractMigration
{
    public function change()
    {

        $this->execute('drop table `xs_user_paid_log`');
        $sql = <<<EEE
        CREATE TABLE `xs_user_paid_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL COMMENT 'user id',
  `days` int(10) NOT NULL COMMENT 'days',
  `pay_or` varchar(20) NOT NULL COMMENT 'pay order',
  `pay_ali_or` varchar(40) NOT NULL COMMENT '2018122122001447550529956375',
  `buyer_id` varchar(30) NOT NULL COMMENT '2088002503747552',
  `trade_status` varchar(15) NOT NULL COMMENT 'TRADE_CLOSED',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单金额',
  `receipt_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '实收金额',
  `invoice_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '开票金额',
  `buyer_pay_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '付款金额',
  `point_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '集分宝金额',
  `pay_time` int(10) NOT NULL DEFAULT 0 COMMENT '用户付款时间',
  `notify_id`  varchar(40) NOT NULL DEFAULT '' COMMENT '2018122100222210157047550597378448',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `create_at` int(10) NOT NULL DEFAULT '0' COMMENT 'create_at',
  PRIMARY KEY (`id`),
  UNIQUE KEY `pay_or_tstatus` (`pay_or`, `trade_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
