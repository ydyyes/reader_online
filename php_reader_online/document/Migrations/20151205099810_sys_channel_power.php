<?php

use Phinx\Migration\AbstractMigration;

class SysChannelPower extends AbstractMigration
{
    public function up()
    {
        $table = $this->table("sys_channel_power");
        $table->addColumn('admin_id', 'integer', ["comment"=>"管理员id"])
              ->addColumn('memo', 'text' ,["comment"=>"权限"])
              ->addColumn('channel_is_show', 'integer', ['limit'=>1, 'default'=>1, "comment"=>"渠道组显示  1:显示,2:不显示"])
              ->addColumn('create_time', 'integer', ["limit"=>10, "comment"=>"创建时间"])
              ->addColumn('update_time', 'integer', ["limit"=>10, "comment"=>"更新时间"])
              ->addColumn('createby', 'string', ["comment"=>"创建人"])
              ->addColumn('updateby', 'string', ["comment"=>"修改人"])
              ->save();
    }
}
