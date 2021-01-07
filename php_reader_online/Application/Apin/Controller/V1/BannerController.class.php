<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Common\Validate\BannerValidate;

class BannerController extends BaseController
{
    protected $no_uuid = 1;
    public function read(){
        $banner_model = D('Admin/CarouselMap');

        if($this->header['channel'])
             $banner_list = $banner_model->getBannerByChannel($this->header['channel']);
        else
            $banner_list = $banner_model->getBanner();

        $this->returnResult(200,'',$banner_list);
    }

}