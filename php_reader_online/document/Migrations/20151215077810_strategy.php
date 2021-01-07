<?php
use Phinx\Migration\AbstractMigration;

class strategy extends AbstractMigration
{
    public function up()
    {
        $table = $this->table('strategy');	
        $table	 ->addColumn('channel_id', 'integer', ["limit"=>50, "comment"=>"渠道id"])
                 ->addColumn('channel_name', 'string', ["limit"=>50, "comment"=>"渠道名称"])
                 ->addColumn('name', 'string', ["limit"=>50, "comment"=>"策略名称"])
                 ->addColumn('cname', 'string', ["limit"=>50, "comment"=>"策略简介"])
    	         ->addColumn('value', 'string', ["limit"=>255, "comment"=>"策略值"])
                 ->addColumn('create_time', 'integer', ["limit"=>10])
                 ->addColumn('update_time', 'integer', ["limit"=>10])
                 ->save();
    }
}