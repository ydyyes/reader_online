<?php


use Phinx\Migration\AbstractMigration;

class ModifyPaid extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `xs_user_paid_log` add column `gamecoin` int(10) NOT NULL DEFAULT 0 COMMENT 'gamecoin' after `days`, add column `type` tinyint(3) NOT NULL DEFAULT 1 COMMENT '1 member; 2 game' after `status`, add index `type`(`type`);";
        $sql .= "insert into `sys_config` values (null, 'PAYMENT_BACK_URL2', 'input', '', 'http://xiaoshuo.enjoynut.cn/api.php?req=notify2', '支付平台推送订单地址2', '', 'string', 'http://xiaoshuo.enjoynut.cn/api.php?req=notify2', 1547708421,1547708421,1);";
        $this->execute($sql);
    }
}
