<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Common\Validate\LoginValidate;
use Common\Validate\MobileValidate;

class CatesController extends BaseController
{
    protected $no_uuid = 1;
    public function read(){
        $cates_model = D('Admin/Cates');
        $cates = $cates_model ->getCates();
        if(!$cates){
            $this->returnResult(400106);
        }
        $this->returnResult(200,'',$cates);

    }


}