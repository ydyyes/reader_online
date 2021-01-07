<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V3;


use Apin\Controller\V1\BaseController;

class ProductListController extends BaseController
{

    public function read(){

        //如果token存在证明有登陆账户
        if (!empty($this->parm['token'])) {
            $this->userinfo = self::check_token($this->parm['token']);
            if (!$this->userinfo) {
                $this->returnResult(300108);
            }
        }

        $product_list = D('Admin/Product') -> getProductList($this->userinfo['uni_id']);

        if(!$product_list){
            $this->returnResult(400106);
        }

        $this->returnResult(200,'',$product_list);
    }
}