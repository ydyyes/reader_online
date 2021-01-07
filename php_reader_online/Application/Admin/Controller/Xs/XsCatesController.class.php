<?php

namespace Admin\Controller\Xs;

use Admin\Controller\SystemController;
use Admin\Model\CatesModel;

/**
 * Class XsCatesController
 * @package Admin\Controller
 */
class XsCatesController extends SystemController
{
    public $model = "cates";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['name']))
        {
            $map['name'] = ['like', '%'.$_search['name'].'%'];
        }
    }

    protected function _list($model, $map, $sortBy='name_path', $asc=true)
    {

        $map = ['pid' => 0];
        if (!$order = I("orderField", "", "trim")) {
            $pk    = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
            $order = ! empty( $sortBy) ? $sortBy : $pk;
            $order = is_array($order) ? join(", ", $order) : $order;
            $_REQUEST['orderField'] = $order;
        }

        //排序方式默认按照倒序排列
        //接受 sost参数 0 表示倒序 非0都 表示正序
        if (isset($_REQUEST['orderDirection'])) {
            $sort = (strtolower($_REQUEST ['orderDirection']) == 'asc') ? 'asc' : 'desc';
        } else {
            $sort = $asc ? 'asc' : 'desc';
            $_REQUEST['orderDirection'] = $sort;
        }

        $_GET[C('VAR_PAGE')] = !empty($_REQUEST[C('VAR_PAGE')])?$_REQUEST[C('VAR_PAGE')]:1;

        //取得满足条件的记录数
        $count = $model->where($map)->count('*');
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

            $p = new \Think\Page( $count, $listRows );
            $voList = $model->where($map)->order($order . " " . $sort)->limit($p->firstRow, $p->listRows)->select();

            $voList = self::getTree($voList);


//            $voList = $model->where(['pid' => 0])->select();


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

    function getTree($data)
    {

        foreach($data as $k => $v)
        {
            $exsit = D('Admin/Cates')->where(['pid' => $v['id']])->select();

            if($exsit)
            {
                $v['chil'] = self::getTree($exsit);

                $data[$k] = $v;
            }else{
                $data[$k]['chil'] = [];
            }
        }
        return $data;
    }


    public function _before(){

        $where['status'] = CatesModel::STATUS_ON;
        $where['pid'] = 0;
        $cates_a[] = '顶级分类';
        $cates = D('Admin/Cates')->where($where)->getField('id,name', true);
        if(!$cates)
            $cates=[];
        $cates = $cates_a + $cates;


        $this->assign('cates',$cates);

    }

    public function _before_insert()
    {
        $msg['name'] = I('post.name');
        $res = D($this->model)->where($msg)->find();
        if(!empty($res))
        {
            $status = D($this->model)->status;
            $this->error('该项已经存在,状态：' . $status[$res['status']]);
        }
        if($_POST['pid']){
            $where['id'] = $_POST['pid'];
            $p_name = D('Admin/Cates')->where($where)->field('name,name_path')->find();
            $_POST['name_path'] =$p_name['name_path'].'_'.$_POST['name'];
            $_POST['level'] =2;
        }else{
            $_POST['name_path'] =$_POST['name'];
            $_POST['level'] =1;
        }
    }

    public function _after_insert()
    {
//        D($this->model)->createCache();
        D($this->model)->clearCates();
    }

    public function _before_update()
    {
        $msg['name'] = I('post.name');
        $res = D($this->model)->where($msg)->find();
        if(!empty($res))
            $this->error('该项已经存在');

        if($_POST['pid']){
            $where['id'] = $_POST['pid'];
            $p_name = D('Admin/Cates')->where($where)->field('name,name_path')->find();
            $_POST['name_path'] =$p_name['name_path'].'_'.$_POST['name'];
            $_POST['level'] =2;
        }else{
            $_POST['name_path'] =$_POST['name'];
            $_POST['level'] =1;

        }
    }

    public function _after_update()
    {
        D($this->model)->clearCates();
    }

    /**
     * 软删除
     */
    public function delete($model_name=null)
    {
        $this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
        $model = D ($modelName);
        if (! empty ( $model )) {
            $pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
            $id = $_REQUEST [$pk];
            if (isset ( $id )) {
                $condition = array ($pk => array ('in', explode ( ',', $id ) ) );
                $data = array('status'=>CatesModel::STATUS_DEL);
                $list = $model->where ( $condition )->save($data);
                if ($list!==false) {
//                    D($this->model)->createCache();
                    D($this->model)->clearCates();
                    $this->success ('删除成功！' );

                } else {
                    $this->log_error($model->getDbError());
                    $this->error ('删除失败！');
                }
            } else {
                $this->error ( '非法操作' );
            }
        }
    }
}