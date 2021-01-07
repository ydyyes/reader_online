<?php


use Phinx\Migration\AbstractMigration;

class TableProduct extends AbstractMigration
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
  CREATE TABLE `xs_product`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_name` varchar(150) NOT NULL,
  `type` tinyint(2) NOT NULL DEFAULT 2 COMMENT '1:首次充值 2:正常套餐 3:折扣套餐',
  `discount_price` decimal(10, 2) NOT NULL DEFAULT 0 COMMENT '折扣之后的价格',
  `price` decimal(10, 2) NOT NULL DEFAULT 0 COMMENT '原价',
  `exchange_time` int(10) NOT NULL COMMENT '会员时间',
  `send_gold` int(10) NULL COMMENT '附赠的金币',
  `explain` varchar(500) NULL DEFAULT '',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 上架 0 下架',
  `create_time` int(10) NOT NULL DEFAULT 0 COMMENT '创建时间',
  `update_time` int(10) NOT NULL DEFAULT 0 COMMENT '修改时间',
  PRIMARY KEY (`id`)
);
EOL;
        $this->execute($sql);


    }
}
