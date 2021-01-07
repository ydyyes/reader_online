<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Common\Validate\IdMustValidate;

class NovelDetailController extends BaseController
{

    public function read(){


         $id = $this->parm['id'];
         $novels_model = D('Admin/Novels');
         $detail = $novels_model->getDetailById($id);
         if(!$detail){
             $this->returnResult(400104);
         }
         //获取推荐书本
         $recommend = $novels_model->getRecommendByMaCate($detail['maCate'],$detail['id']);
         $data['detail'] = $detail;
         $data['recommend'] = $recommend?:[];


         $this->returnResult(200,'',$data);

    }

    protected function _check_para($data)
    {
        (new IdMustValidate())->gocheck($data);
    }


    }