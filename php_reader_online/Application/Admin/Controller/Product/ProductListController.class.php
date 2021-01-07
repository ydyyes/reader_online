<?php
/**
 * User:Xxx
 */

namespace Admin\Controller\Product;


use Admin\Controller\SystemController;
use Admin\Model\ProductModel;

class ProductListController extends SystemController
{
    public $model = "product";

    public function _before(){
        $type   = D($this->model) -> type;
        $status = D($this->model) -> status;
        $p_type = I('post.type');

        if($p_type == ProductModel::FISTER){

           $first = D($this->model)->where(['type' => $type ])->find();
           if($first){
               $this -> error('首次优惠套餐已经存在');
           }
        }
        $_POST['discount_price'] = sprintf('%.2f',$_POST['discount_price']);
        $_POST['price'] = sprintf('%.2f',$_POST['price']);

        $this->assign('type', $type);
        $this->assign('status', $status);

    }

    public function _after_insert(){
        D($this->model) -> clearProductList();
    }
    public function _after_update(){
        D($this->model) -> clearProductList();
    }

}