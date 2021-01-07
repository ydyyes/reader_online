<?php

namespace Admin\Controller\Xs;

use Admin\Controller\SystemController;
use Admin\Controller\UploadChapterController;
use Admin\Model\CatesModel;
use Think\Model;

/**
 * Class XsNovelsController
 * @package Admin\Controller
 */
class XsSourceController extends SystemController
{


    protected  $files = [];

    public function _filter(&$map)
    {
        $_search = search_map();

        if (isset($_search['id']))
        {
            $this->files['id'] = $_search['id'];
        }
        if (isset($_search['title']))
        {
            $this->files['title'] = ['like', '%'.$_search['title'].'%'];
        }
        if (isset($_search['author']))
        {
            $this->files['author'] = ['like', '%'.$_search['author'].'%'];
        }
        if (isset($_search['over']))
        {
            $this->files['over'] = intval($_search['over']);
        }
        if (isset($_search['copyright']))
        {
            $this->files['copyright'] = ['like', '%'.$_search['copyright'].'%'];
        }
        if (isset($_search['openlevel']))
        {
            $this->files['openlevel'] = $_search['openlevel'];
        }
        if (isset($_search['manualUpdate']))
        {
            $this->files['manualUpdate'] = $_search['manualUpdate'];
        }

        if (isset($_search['maCate']))
        {
            $this->files['maCate'] = $_search['maCate'];
        }
        if (isset($_search['type']))
        {
            $this->files['type'] = $_search['type'];
        }
        if (isset($_search['status']))
        {
            $this->files['status'] = $_search['status'];
        }

    }


    /**
     * 默认恢复操作
     *
     * @access public
     * @return string
     * @throws FcsException
     */
    function resume()
    {

        $DB =  array(
            'db_type'  => 'mysql',
            'db_user'  => 'admin_center',
            'db_pwd'   => C('EXPORT_DB_PWD'),
            'db_host'  => '192.168.232.248',
            'db_port'  => '3306',
            'db_name'  => 'data_center',
            'db_charset'=>'utf8',
            'DB_PARAMS'  => array(\PDO::ATTR_CASE => \PDO::CASE_NATURAL)
        );

        $connect = (new Model())->db("2",$DB);
        $res = $connect->table('novel_details')->where(['id' => $_GET['id']])->save(['manualUpdate'=>1]);
        if (false !== $res) {
            $this->assign ( "jumpUrl", $this->getReturnUrl () );
            $this->success ( '状态恢复成功！' );
        } else {
            $this->error ( '状态恢复失败！' );
        }
    }

    public function forbid($model_name=null)
    {
        $DB =  array(
            'db_type'  => 'mysql',
            'db_user'  => 'admin_center',
            'db_pwd'   => C('EXPORT_DB_PWD'),
            'db_host'  => '192.168.232.248',
            'db_port'  => '3306',
            'db_name'  => 'data_center',
            'db_charset'=>'utf8',
            'DB_PARAMS'  => array(\PDO::ATTR_CASE => \PDO::CASE_NATURAL)
        );

        $connect = (new Model())->db("2",$DB);
        $res = $connect->table('novel_details')->where(['id' => $_GET['id']])->save(['manualUpdate'=>0]);
        if ($res!==false) {
            $this->assign ( "jumpUrl", $this->getReturnUrl () );
            $this->success ( '状态禁用成功' );
        } else {
            $this->error  (  '状态禁用失败！' );
        }
    }




    public function index()
    {
        if (method_exists ( $this, '_filter' )) {
            $this->_filter ( $map );
        }
        $map = $this->files;


         $this->_list ( '', $map );


        $this->assign ('map', $map);
        $this->display ();
        return;
    }


    /**
     * 根据表单生成查询条件
     * 进行列表过滤
     * @access protected
     * @param Model $model 数据对象
     * @param HashMap $map 过滤条件
     * @param string $sortBy 排序
     * @param boolean $asc 是否正序
     * @return void
     * @throws ThinkExecption
     */
    protected function _list($model, $map)
    {

        $DB =  array(
            'db_type'  => 'mysql',
            'db_user'  => 'admin_center',
            'db_pwd'   => C('EXPORT_DB_PWD'),
            'db_host'  => '192.168.232.248',
            'db_port'  => '3306',
            'db_name'  => 'data_center',
            'db_charset'=>'utf8',
            'DB_PARAMS'  => array(\PDO::ATTR_CASE => \PDO::CASE_NATURAL)
        );

        $connect = (new Model())->db("2",$DB);

        //取得满足条件的记录数
        $count = $connect->table('novel_details')->where($map)->count('*');


        \Think\Log::write($model->_sql, \Think\Log::DEBUG);

        if ($count > 0) {
            //创建分页对象
            if(!empty( $_REQUEST['numPerPage'] )) {
                $listRows = intval($_REQUEST ['numPerPage']) ? intval($_REQUEST ['numPerPage']) : C('PAGE_LISTROWS');
                cookie("numPerPage", intval($_REQUEST ['numPerPage']));
            }
            if(cookie("numPerPage") > 0) {
                $listRows = cookie("numPerPage");
                cookie("numPerPage", $listRows);
            }


            $listRows = empty($listRows) ? C('PAGE_LISTROWS') : $listRows;
            $_GET[C('VAR_PAGE')]=$_REQUEST[C('VAR_PAGE')];
            $p = new \Think\Page( $count, $listRows );


            if($_REQUEST['_search']['order_manualUpdate']){
                $order = 'latelyFollower';
                $sort = 'desc';
                cookie('order_manualUpdate',1);
            }else{
                $order = 'id';
                $sort = 'desc';
                cookie('order_manualUpdate',null);
            }

            $voList = $connect->table('novel_details')->where($map)->order($order . " " . $sort)->limit($p->firstRow, $p->listRows)->select();
            //当页面只需要返回数据
            if(method_exists($this, '_after_select'))
                call_user_func_array(array($this, '_after_select'), array(&$voList));

            //分页跳转的时候保证查询条件
            foreach ( $map as $key => $val ) {
                if (! is_array ( $val ))
                    $p->parameter .= "$key=" . urlencode ( $val ) . "&";
            }

            //分页显示

            $page = $p->show ();

            //列表排序显示
            $sortImg = $sort; //排序图标
            $sortAlt = $sort == 'desc' ? '升序排列' : '倒序排列'; //排序提示
            $sort = $sort == 'desc' ? 1 : 0; //排序方式

            //模板赋值显示
            $this->assign ( 'list', $voList );
            $this->assign ( 'sort', $sort );
            $this->assign ( 'order', $order );
            $this->assign ( 'sortImg', $sortImg );
            $this->assign ( 'sortType', $sortAlt );
            $this->assign ( "page", $page );
        }
        $this->assign ( 'totalCount', $count );
        $this->assign ( 'numPerPage', $listRows );
        $this->assign ( 'currentPage', !empty($_REQUEST[C('VAR_PAGE')]) ? $_REQUEST[C('VAR_PAGE')] : 1);

        cookie ( '_currentUrl_', __SELF__ );
        return;
    }






}