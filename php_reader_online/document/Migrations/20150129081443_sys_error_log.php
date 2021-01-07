<?php

use Phinx\Migration\AbstractMigration;

class SysErrorLog extends AbstractMigration
{
	public function up()
	{
		$table = $this->table('think_sys_error_log');
		$table	->addColumn('status', 'integer', ["limit"=>1, "comment"=>"0:未处理, 1:已通知, 2:无法解决, 3:已解决"])
				->addColumn('msg', 'string', ["comment"=>"错误提示"])
				->addColumn('level', 'string', ["comment"=>"错误级别"])
				->addColumn('url', 'string', ["comment"=>"访问域名"])
				->addColumn('env', 'text', ["comment"=>"环境变量"])
				->addColumn('backtrace', 'text', ["comment"=>"错误堆栈"])
				->addColumn('create_time', 'integer', ["limit"=>10])
				->addColumn('update_time', 'integer', ["limit"=>10])
				->save();
	}
}