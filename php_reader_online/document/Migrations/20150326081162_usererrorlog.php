<?php
use Phinx\Migration\AbstractMigration;

class usererrorlog extends AbstractMigration
{

    public function up()
    {
        $table = $this->table('think_user_error_log');	
        $table	 ->addColumn('device_imei', 'string', ["limit"=>50, "comment"=>"用户IMEI信息"])
                 ->addColumn('device_channel', 'string', ["limit"=>50, "comment"=>"渠道信息"])
                 ->addColumn('device_vcode', 'string', ["limit"=>50, "comment"=>"版本"])
    	         ->addColumn('device_mc', 'string', ["limit"=>50, "comment"=>"用户网卡信息"])
      	         ->addColumn('device_model', 'string', ["limit"=>50, "comment"=>"用户手机型号"])
       		     ->addColumn('errorlog', 'text', ["comment"=>"错误信息"])
                 ->addColumn('create_time', 'integer', ["limit"=>10])
                 ->addColumn('update_time', 'integer', ["limit"=>10])
                 ->save();
    }
}