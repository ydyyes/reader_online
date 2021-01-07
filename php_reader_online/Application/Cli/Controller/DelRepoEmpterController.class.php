<?php
/**
 * User:Xxx
 */

namespace Cli\Controller;


use Think\Model;

class DelRepoEmpterController extends ClibaseController
{
    public function start(){
        $novels_model = D('Admin/Novels');
        $data = $novels_model->field('_id')->select();

        $DB =  array(
            'db_type'  => 'mysql',
            'db_user'  => 'reader_center',
            'db_pwd'   => C('EXPORT_DB_PWD'),
            'db_host'  => '192.168.232.245',
            'db_port'  => '3306',
            'db_name'  => 'data_center',
            'db_charset'=>'utf8',
            'DB_PARAMS'  => array(\PDO::ATTR_CASE => \PDO::CASE_NATURAL)
        );

        $connect = (new Model())->db("1",$DB);
        try {

            foreach ($data as $val) {

                $source_data = $connect->table('novel_details')->where("_id = '$val[_id]'")->find();

                if(!$source_data){
                    $novels_model->where("_id = '$val[_id]'")->delete();

                    echo '@@D_['.$val['_id'].'@@@';
                }else{

                    echo 'Y_['.$val['_id'].']__';
                }
            }
        }catch (\Exception $e){
            echo $e->getMessage();exit;
        }



    }

}