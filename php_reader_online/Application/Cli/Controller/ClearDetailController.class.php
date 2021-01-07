<?php
namespace Cli\Controller;

class ClearDetailController extends ClibaseController
{
    public function clear(){

        if(C("REDIS_PASSWORD")){
            $command = sprintf(  "redis-cli -h %s -p %s -a %s keys %sdetail_* | xargs redis-cli -h %s -p %s  -a %s DEL",C('REDIS_HOST'),C("REDIS_PORT"),C("REDIS_PASSWORD"),C("REDIS_PREFIX"),C('REDIS_HOST'),C("REDIS_PORT"),C("REDIS_PASSWORD"));
        }else{
            $command = sprintf(  "redis-cli -h %s -p %s  keys %sdetail_* | xargs redis-cli -h %s -p %s  DEL",C('REDIS_HOST'),C("REDIS_PORT"),C("REDIS_PREFIX"),C('REDIS_HOST'),C("REDIS_PORT"));
        }
       `$command`;
       echo 'done';
    }
}