<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\NovelsModel;
use Common\Validate\IdMustValidate;

class ChapterListController extends BaseController
{
    public function read(){

        $id = $this->parm['id'];
        $where['status'] = NovelsModel::STATUS_ON;
        $novels_model = D('Admin/Novels');
        $path_chapter = $novels_model->getDetailById($id,1);
        if(empty($path_chapter['pathChapters'])){
            $this->returnResult(200,'',[]);
        }
        $path_chapter = fetchIndex($path_chapter['pathChapters']);
        $path_chapter=file_get_contents($path_chapter);

        if(!$path_chapter){
            $this->returnResult(400108,'');
        }
        $format_list = $novels_model->formatList($path_chapter);

        if(!$format_list){
            $this->returnResult(400108,'');
        }

        return $this->returnResult(200,'',$format_list);

    }
    protected function _check_para($data)
    {
        (new IdMustValidate())->gocheck($data);
    }


}