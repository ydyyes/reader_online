<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\NovelsModel;
use Common\Controller\Datasource;
use Common\Validate\ChapterInfoValidate;
use Think\Controller;

class ChapterInfoController extends BaseController
{

    public function read(){

        $id = $this->parm['id'];
        $label = $this->parm['label'];
        $where['status'] = NovelsModel::STATUS_ON;
        $novels_model = D('Admin/Novels');
        $path_chapter = $novels_model->getDetailById($id,1);
        if(empty($path_chapter['pathChapters'])){
            $this->returnResult(400106,'');
        }

        $path_url = $novels_model->formatInfo($path_chapter['pathChapters'],$label);

        if(!$path_url){
            $this->returnResult(400106,'');
        }

        $this->returnResult(200,'',['url'=>$path_url]);

    }
    protected function _check_para($data)
    {
        (new ChapterInfoValidate())->gocheck($data);
    }


}