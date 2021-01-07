<?php
/**
 * Created by PhpStorm.
 * User: liubingxuan
 * Date: 2019-03-07
 * Time: 14:17
 */

namespace Cli\Controller;


use Admin\Model\NovelsModel;
use Think\Db;
use Think\Model;

class BookExportController extends ClibaseController
{
    public function start(){
       $DB =  array(
            'db_type'  => 'mysql',
            'db_user'  => 'reader_center',
            'db_pwd'   => C('EXPORT_DB_PWD'),
            'db_host'  => '192.168.232.248',
            'db_port'  => '3306',
            'db_name'  => 'data_center',
            'db_charset'=>'utf8',
            'DB_PARAMS'  => array(\PDO::ATTR_CASE => \PDO::CASE_NATURAL)
        );

        $connect = (new Model())->db("1",$DB);
        $source_field = $connect->query('show columns from novel_details');
        $target_field = M('')->query('show columns from xs_novels');
//        foreach ($target_field as $k => $v){
//            if(in_array($v['Field'],$unset)){
//                unset($target_field[$k]);
//            }
//        }
        $source_field = array_column($source_field,'field');

        $target_field = array_column($target_field,'Field');


        $result = array_intersect($source_field,$target_field);


        $field = implode(',',$result);
        $novels_model = D('Admin/Novels');


       $source_data = $connect->table('novel_details')->field($field)->select();
       foreach ($source_data as $kk => $vv){
           $vv['so_id'] = $vv['id'];
           unset($vv['id']);
           $ma_cate = D('Admin/Cates')->getCateByName($vv['majorCate']);
           if($ma_cate){
               $vv['maCate'] = $ma_cate['id'];
           }
           $min_cate = D('Admin/Cates')->getCateByName($vv['minorCate']);

           if($min_cate){
               $vv['minCate'] = $min_cate['id'];
           }
           if($vv['gender'] == 'male' ){
               $vv['gender'] = '1';
           }elseif($vv['gender'] == 'female'){
               $vv['gender'] = '2';
           }else{
               $vv['gender'] = '0';
           }

           $exist = $novels_model ->where("_id = '$vv[_id]' ")->field('id')->find();
           if(!$exist){
               $novels_model->add($vv);
           }else{
               //这2个字段是应急字段 修改之后删除
               //$save['pathChapters'] = $vv['pathChapters'];
               //$save['cover'] = $vv['cover'];

               $save['realchaptersCount'] = $vv['realchaptersCount'];
               $save['chaptersCount'] = $vv['chaptersCount'];
               $save['updated'] = $vv['updated'];
               $save['wordCount'] = $vv['wordCount'];
               $save['update_at'] = $vv['update_at'];

               if($vv['updated'] > $exist['updated']){
                   $save['lastChapter'] = $vv ['lastChapter'];
               }
               $novels_model->where("_id = '$vv[_id]'")->save($save);
           }
           echo $vv['_id'].'__';
       }

       echo 'done';

    }


}