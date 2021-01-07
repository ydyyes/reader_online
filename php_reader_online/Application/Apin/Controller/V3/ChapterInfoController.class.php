<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V3;


use Admin\Model\NovelsModel;
use Apin\Controller\V1\BaseController;
use Common\Controller\Datasource;
use Common\Validate\ChapterInfoValidate;

class ChapterInfoController extends BaseController
{
    public function read(){

        $id = $this->parm['id'];
        $label = $this->parm['label'];
        $novels_model = D('Admin/Novels');

        $redis = Datasource::getRedis('instance1');
        $url = $redis->hget($novels_model -> novelChapterListCacheKey($id), $label);

        if($url) {
            $url = get_chapter_info($url);
            return $this->returnResult(200, '', ['url' => $url]);
        }else{
            $where['status'] = NovelsModel::STATUS_ON;
            $path_chapter = $novels_model->getDetailById($id, 1);
            if (empty($path_chapter['pathChapters'])) {
                $this->returnResult(400106, '');
            }


            $path_chapter = fetchIndex($path_chapter['pathChapters']);
            $chapter_list = file_get_contents($path_chapter);
            if (!$chapter_list) {
                $this->returnResult(400106, '');
            }


            $url = $novels_model->vthScanChapterInfo($chapter_list, $label);

            if ($url) {
                //进入队列,预储备
                $novels_model->pushNovels($id, $chapter_list);

                return $this->returnResult(200, '', ['url' => $url]);
            }
        }


        return $this->returnResult(400106);





    }

    protected function _check_para($data)
    {
        (new ChapterInfoValidate())->gocheck($data);
    }


}