<?php


use Phinx\Migration\AbstractMigration;

class TableOrder extends AbstractMigration
{
    /**
     * Change Method.
     *
     * Write your reversible migrations using this method.
     *
     * More information on writing migrations is available here:
     * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
     *
     * The following commands can be used in this method and Phinx will
     * automatically reverse them when rolling back:
     *
     *    createTable
     *    renameTable
     *    addColumn
     *    renameColumn
     *    addIndex
     *    addForeignKey
     *
     * Remember to call "create()" or "update()" and NOT "save()" when working
     * with the Table class.
     */
    public function change()
    {
        $sql = <<<EOL
CREATE TABLE  `xs_order`  (
  `id` integer(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_sn` varchar(40) NOT NULL COMMENT '订单号',
  `u_id` int(10) NOT NULL COMMENT '用户id',

  `pay_type` tinyint(4) NULL DEFAULT 0 COMMENT '1:微信 2支付宝 0 其他',
  `pay_source` tinyint(1) NULL DEFAULT 2 COMMENT '支付来源 1 PC 2 M',
  `total_price` decimal(10, 2) NOT NULL COMMENT '商品表未折扣之前的金额',
  `pay_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '订单实付金额',
  `pay_in_money` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '扣点后所得的金额',
  `order_type` varchar(30) NOT NULL DEFAULT '' COMMENT '订单类型',
  `ratio` float NULL DEFAULT 0 COMMENT '所扣的点',
  `pay_sn` varchar(150)  COMMENT '第三方流水号',
  `note` text NULL COMMENT '备注信息',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0.待支付，1支付中，2.支付成功，3.支付失败，4.退款，5.关闭，6.撤销，7.取消，8.异常',
  `pay_time` int(10) NOT NULL DEFAULT 0 COMMENT '支付的时间',
  `update_time` int(10) NOT NULL DEFAULT 0 COMMENT '最后一次更新时间',
  `create_time` int(10) NOT NULL DEFAULT 0 COMMENT '订单创建时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `order_sn`(`order_sn`) USING HASH,
  INDEX `u_id`(`u_id`) USING BTREE,
  INDEX `status`(`status`) USING HASH,
  INDEX `create_time`(`create_time`) USING BTREE
);

CREATE TABLE `xs_order_item`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL COMMENT '订单ID',
  `u_id` int(10) NOT NULL COMMENT '用户ID',
  `quantity` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '购买的数量',
  `price` decimal(10, 2) NOT NULL COMMENT '商品原价',
  `discount_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '当前的价格',
  `p_id` int(10) NOT NULL COMMENT '商品ID ',
  `p_name` varchar(150) NULL COMMENT '商品名称',
  `p_time` int(10) NOT NULL DEFAULT 0 COMMENT '商品的时间 单位:天',
  `p_gold` int(9) NULL DEFAULT 0 COMMENT '商品赠送的金币',
  `p_type` varchar(20) NULL DEFAULT NULL COMMENT '商品类型',
  `note` text NULL COMMENT '描述',
  `create_time` int(10) NULL,
  `update_time` int(10) NULL,
  PRIMARY KEY (`id`),
  INDEX `order_id`(`order_id`) USING HASH,
  INDEX `p_id`(`p_id`, `p_name`) USING BTREE
);


CREATE TABLE `xs_order_callback_data`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL COMMENT '订单ID',
  `pay_data` text NULL COMMENT '支付回调信息',
  `refund_data` text NULL COMMENT '退款回调信息',
  `create_time` int(10) NOT NULL DEFAULT 0,
  `update_time` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `order_id`(`order_id`) USING HASH
);

            
EOL;
        $this->execute($sql);

    }
}
