<?php


use Phinx\Migration\AbstractMigration;

class UpdateCoinOrders extends AbstractMigration
{
    public function up()
    {
        $sql = <<<EEE
        CREATE TABLE `xs_update_coin_orders` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `serial` varchar(20) NOT NULL COMMENT 'order no',
  `uid` int(10) NOT NULL COMMENT 'user id',
  `guser` varchar(32) NOT NULL COMMENT 'game username',
  `amount` int(10) NOT NULL DEFAULT '0' COMMENT '金额可为正整数或负整数或0。',
  `updatefrom` tinyint(3) NOT NULL COMMENT '1=结算，2=投注，3=押金，若有其他来源种类将追加……',
  `create_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial` (`serial`)
  ) ENGINE=INNODB DEFAULT CHARSET=utf8;
EEE;
        $this->execute($sql);
    }
}
