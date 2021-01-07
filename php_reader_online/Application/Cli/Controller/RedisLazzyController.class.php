<?php
namespace Cli\Controller;

class RedisLazzyController extends ClibaseController
{
    function draw_logs_insert()
    {
        $model = new \Gold\Model\DrawLogsModel();
        $model->lazzy_insert();
    }
}