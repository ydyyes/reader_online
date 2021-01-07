<?php
/**
 * User:Xxx
 */

namespace Admin\Controller\User;


use Admin\Controller\SystemController;

class UserGoldExchangeController extends SystemController
{
    public $model = "GoldLog";
    public function _filter(&$map)
    {
        $_search = search_map();

        $map['eid'] = ['neq','0'];

        if (isset($_search['uid']))
        {
            $map['uid'] = $_search['uid'];
        }
        if (isset($_search['name']))
        {
            $map['name'] = ['like','%'.$_search['name'].'%'];
        }
    }

    protected function _list($model, $map, $sortBy='', $asc=false)
    {

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