<?php
$db = include 'database.php';

return array(
	"paths" => array(
		"migrations" => "document/Migrations"
	),
	"environments" => array(
		"default_migration_table" => "phinx_logs",
		"default_database" => "dev",
		"dev" => array(
				"adapter" => "mysql",
				"charset" => "utf8",
				"host" => $db['DB_HOST'],
				"name" => $db['DB_NAME'],
				"user" => $db['DB_USER'],
				"pass" => $db['DB_PWD'],
				"port" => $db['DB_PORT']
		)
	)
);