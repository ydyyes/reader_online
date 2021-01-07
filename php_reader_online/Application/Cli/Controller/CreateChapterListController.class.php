<?php
/**
 * User:Xxx
 */

namespace Cli\Controller;


use Admin\Model\NovelsModel;
use Common\Controller\Datasource;

class CreateChapterListController extends ClibaseController
{
    public function start(){
        $redis = Datasource::getRedis('instance1');
        $novels_model = D('Admin/Novels');
        while($val = $redis->lpop($novels_model->pushNovelChapterLisCacheKey())){

            $path_chapter = $novels_model -> getDetailById($val,1);


            if(empty($path_chapter['pathChapters'])){
                break;
            }
            $ctx = stream_context_create(array(
                    'http' => array(
                        'timeout' => 5
                    )
                )
            );

            $path_chapter = fetchIndex($path_chapter['pathChapters']);
            $chapter_list=file_get_contents($path_chapter,false,$ctx);

            if(!$chapter_list){
                break;
            }


            $list = $novels_model -> yevthFormatList($chapter_list,0);
            $redis->pipeline();
            foreach ($list as  $info) {
               $redis->hset($novels_model -> novelChapterListCacheKey($val), $info['_label'], $info['link']);

            }
            $redis->EXPIRE($novels_model -> novelChapterListCacheKey($val), NovelsModel::NOVEL_LIST_TIME_OUT + ($val*10));
            $redis->exec();



        }
        echo 'done';
    }

}