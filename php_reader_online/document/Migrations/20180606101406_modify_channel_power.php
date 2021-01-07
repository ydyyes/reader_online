<?php


use Phinx\Migration\AbstractMigration;

class ModifyChannelPower extends AbstractMigration
{
    public function change()
    {
        $sql = "alter table `sys_channel_power` modify COLUMN `create_time` int(10) NOT NULL DEFAULT 0 COMMENT '创建时间',modify COLUMN `update_time` int(10) NOT NULL DEFAULT 0 COMMENT '更新时间',modify COLUMN `createby` varchar(255) NOT NULL DEFAULT '' COMMENT '创建人',modify COLUMN `updateby` varchar(255) NOT NULL DEFAULT '' COMMENT '修改人';";
        $this->execute($sql);
    }
}
