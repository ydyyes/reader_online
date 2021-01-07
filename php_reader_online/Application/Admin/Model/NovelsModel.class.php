<?php
namespace Admin\Model;
use Common\Controller\Datasource;

/**
 * Class NovelsModel
 * @package Admin\Model
 */
class NovelsModel extends SystemModel
{
	protected $trueTableName = 'xs_novels';

	protected $_validate = array(
	    array('title','require','title不能为空！'),
	);
	
	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
        array('update_at','time',self::MODEL_INSERT,'function'),
        array('update_at','time',self::MODEL_UPDATE,'function'),
//        array('book_update','time',self::MODEL_INSERT,'function'),
//        array('book_update','time',self::MODEL_UPDATE,'function'),
	);

	const OPENLEVEL_1 = 1;
	const OPENLEVEL_2 = 2;
    const OPENLEVEL_3 = 3;

	const OVER_YES = 1;
	const OVER_NO = 0;

	const STATUS_DEL = -1;
    const STATUS_OFF = 0;
	const STATUS_ON = 1;

	const GENDER_1 = 1;
	const GENDER_2 = 2;

	public $status = [
	    self::STATUS_ON => '上架',
        self::STATUS_OFF => '下架',
    ];

	public $over = [
	    self::OVER_NO => '连载中',
        self::OVER_YES => '完结',
    ];

	public $openlevel = [
	    self::OPENLEVEL_3 => '严重',
        self::OPENLEVEL_2 => '一般',
        self::OPENLEVEL_1 => '擦边'
    ];

    public $gender = [
    	self::GENDER_1 => 'female',
    	self::GENDER_2 => 'male',
    ];
    const COMMENT_YES =1;
    const COMMENT_NO =0;
    public $comment_real = [
        self::COMMENT_YES => '是',
        self::COMMENT_NO => '否',
    ];

    const COPYRIGHT_YES =1;
    const COPYRIGHT_NO =0;
    public $copyright = [
        self::COPYRIGHT_YES => '是',
        self::COPYRIGHT_NO => '否',
    ];
    const FREE_YES =1;
    const FREE_NO =0;
    public $free = [
        self::FREE_YES => '是',
        self::FREE_NO => '否',
    ];
    const MOTH_YES =1;
    const MOTH_NO =0;
    public $moth = [
        self::MOTH_YES => '是',
        self::MOTH_NO => '否',
    ];
    const Newchart_hot ='hot';
    const Newchart_new ='new';
    const Newchart_reputation ='reputation';
    const Newchart_over ='over';

    public $Newcharts = [
        self::Newchart_hot => '热门榜',
        self::Newchart_new => '新书榜',
        self::Newchart_reputation => '口碑榜',
        self::Newchart_over => '完结榜',
    ];

    const SERIRAL_YES =1;
    const SERIRAL_NO =0;
    public $seriral = [
        self::SERIRAL_YES => '是',
        self::SERIRAL_NO => '否',
    ];
    //
    const MAN = 1;
    const WOMEN = 2;
    const UNLIMITE =0;

    public $crowd = [
        self::MAN => '男',
        self::WOMEN => '女',
        self::UNLIMITE => '不限',
    ];

    //设置过期时间
    const CATES_TIMEOUT = 7200;
    const CACHE_NUM = 100;

    //推荐数
     const RECOMMEND_COUNT = 30;
     const RECOMMEND_NUM   = 6;

     //热键key
    const HOT_KET_END = 9;
    const LIMIT_HOT_KET = 2000;


    //预储备key过期时间
    const NOVEL_LIST_TIME_OUT = 2592000;


    /*
     *  预储备
     * */

    public function pushNovels($id,$chapter_list){
        $redis = Datasource::getRedis('instance1');

        //防止未执行,重复加载
        if ($redis->set(self::lockPushNovelChapterList($id) . '_lock', 1, ['nx', 'ex' => 300])) {
                $redis -> rpush(self::pushNovelChapterLisCacheKey(),$id);

        }

    }


    public  function novelChapterListCacheKey($id){

        return  C('REDIS_PREFIX').'novel_chapter_list_'.$id;
    }

    public function pushNovelChapterLisCacheKey(){

        return  C('REDIS_PREFIX').'push_novel_chapter_list';
    }

    private function lockPushNovelChapterList($id){

        return C('REDIS_PREFIX').'push_novel_chapter_'.$id;
    }

    /*
     * 缓存不存在,搜索章节索引文件
     *
     */

    public function vthScanChapterInfo($data,$label){
           $data = self::vthFormatList($data,0);
           $data_list = array_column($data,'link','_label');
           $key = array_key_exists($label,$data_list);

           $res = '';
           if($key){
               $res = get_chapter_info($data_list[$label]);


           }
           return $res;


    }


    /**
     * @param $key
     * @param $page 搜索
     * @param $size
     * @return mixed
     */
     public function SearchList($key, $page, $size ){
         $where['_string'] = "(title like '%{$key}%') OR (author like '%{$key}%')";
         $where['status'] = self::STATUS_ON;
         $list = self::where($where)
             ->field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
             ->page($page,$size)
             ->select();
         if ($list) {
             $list = array_map('callbackImg', $list);
         }



         return $list;

     }

     public function hotCacheKey(){
         return C('REDIS_PREFIX').'hot_key';
     }
    /*
     * 推荐列表
     */
     public function RecommedList($where='',$page = 1,$size = 6 ,$channel_id = ''){
         $where['a.status'] = self::STATUS_ON;
         $where['b.status'] = self::STATUS_ON;
         $where['b.chn_id'] = ['like','%'.$channel_id.',%'];

         $order = 'rating desc,updated desc';
         $start = ($page-1)*$size;
         $end   = ($start+$size)-1;
         $redis = Datasource::getRedis('instance1');
         $list_res = [];

         if(!isset($where['gender'])) {
             $list = $redis->lrange(self::recommendListCacheKey('',$channel_id), $start, $end);
             $cache_len = $redis->llen(self::recommendListCacheKey('',$channel_id));

             if(count($list) != $size){
                 $list = [];
             }

             if (!$list) {
                 $list = self::alias('a')
                     ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                     ->join('xs_recommend as b on a.id = b.nid')
                     ->where($where)
                     ->limit($start,$size)
                     ->order($order)
                     ->select();


                 if($list){
                      $list =  array_map('callbackImg', $list);
                 }

                 if (!$cache_len) {
                     $cache_data = self::alias('a')
                         ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                         ->join('xs_recommend as b on a.id = b.nid')
                         ->where($where)
                         ->limit(self::RECOMMEND_COUNT)
                         ->order($order)
                         ->select();
                     if($cache_data){
                         $cache_data = array_map('callbackImg', $cache_data);
                     }


                     if($cache_data) {
                         if ($redis->set(self::recommendListCacheKey('',$channel_id) . '_lock', 1, ['nx', 'ex' => 180])) {
                             $redis->pipeline();
                             foreach ($cache_data as $k => $v) {
                                 $redis->rpush(self::recommendListCacheKey('',$channel_id), serialize($v));
                             }
                             $redis->EXPIRE(self::recommendListCacheKey('',$channel_id), self::CATES_TIMEOUT + 3600);
                             $redis->exec();
                             $redis->del(self::recommendListCacheKey('',$channel_id) . '_lock');
                         }
                     }

                 }

             }else{
                 foreach ($list as $k => $v){
                     $list[$k]= unserialize($v);
                     }
             }
         }else {
             if($where['gender'] == 1){
                 $where['gender'] = ['neq',2];
             }elseif($where['gender'] == 2){
                 $where['gender'] = ['neq',1];
             }else{
                 $where['gender'] = ['not in','1,2'];
             }
             $list = $redis->lrange(self::recommendListCacheKey($where['gender'],$channel_id), $start, $end);
             $cache_len = $redis->llen(self::recommendListCacheKey($where['gender'],$channel_id));
             if(count($list) != $size){
                 $list = [];
             }
             if (!$list) {
                 $list = self::alias('a')
                     ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                     ->join('xs_recommend as b on a.id = b.nid')
                     ->where($where)
                     ->limit($start,$size)
                     ->order($order)
                     ->select();


                 if ($list) {
                     $list = array_map('callbackImg', $list);
                 }

                 if (!$cache_len) {
                     $cache_data = self::alias('a')
                         ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                         ->join('xs_recommend as b on a.id = b.nid')
                         ->where($where)
                         ->limit(self::RECOMMEND_COUNT)
                         ->order($order)
                         ->select();
                     if ($cache_data) {
                         $cache_data = array_map('callbackImg', $cache_data);
                     }

                     if ($cache_data) {
                         if ($redis->set(self::recommendListCacheKey($where['gender'],$channel_id) . '_lock', 1, ['nx', 'ex' => 180])) {
                             $redis->pipeline();
                             foreach ($cache_data as $k => $v) {
                                 $redis->rpush(self::recommendListCacheKey($where['gender'],$channel_id), serialize($v));
                             }
                             $redis->EXPIRE(self::recommendListCacheKey($where['gender'],$channel_id), self::CATES_TIMEOUT + 3600);
                             $redis->exec();
                             $redis->del(self::recommendListCacheKey($where['gender'],$channel_id) . '_lock');
                         }
                     }

                 }

             } else {
                 foreach ($list as $k => $v) {
                     $list[$k] = unserialize($v);

                 }
             }
         }



         return $list;

     }

     public function recommendListCacheKey($gender = '',$channel){
         if($gender){
             return C('REDIS_PREFIX').'recommend_list_bookstore_'.$gender.'_'.$channel;
         }else{
             return  C('REDIS_PREFIX').'recommend_list_bookstore_all'.'_'.$channel;
         }
     }

    public  function yevthFormatList($data,$order = 1){

        $list = json_decode($data,true);
        if(!is_array($list['chapters'])){
            return false;
        }
        if($order)
            array_multisort(array_column($list['chapters'],'rename'),SORT_ASC,SORT_NUMERIC,$list['chapters']);

        foreach ($list['chapters'] as $k => &$v){
            if($v['unreadble']){
                $v['_label'] = crc32($v['link']);
                if($order)
                    unset($v['link'],$v['unreadble'],$v['rename']);
                else
                    unset($v['unreadble'],$v['rename']);

                yield $v;
            }else{
                unset($list['chapters'][$k]);
            }

        }



    }

     public  function vthFormatList($data,$order = 1){

         $list = json_decode($data,true);
         if(!is_array($list['chapters'])){
             return false;
         }
         if($order)
            array_multisort(array_column($list['chapters'],'rename'),SORT_ASC,SORT_NUMERIC,$list['chapters']);

         foreach ($list['chapters'] as $k => &$v){
             if($v['unreadble']){
                 $v['_label'] = crc32($v['link']);
                 if($order)
                     unset($v['link'],$v['unreadble'],$v['rename']);
                 else
                     unset($v['unreadble'],$v['rename']);
             }else{
                 unset($list['chapters'][$k]);
             }

         }


         return $list['chapters']?:[];

     }
    /**  随机下发推荐
     * @param string $where
     * @param string $order
     */
    public function randRecommend($where='',$order=''){
        $where['a.status'] = self::STATUS_ON;
        $where['b.status'] = self::STATUS_ON;
        $order = 'b.rating desc,updated desc';
        $redis = Datasource::getRedis('instance1');

        if(empty($where['gender'])) {
            $data = $redis->srandmember(self::randRecommendCacheKey(),self::RECOMMEND_NUM);

            if(!$data) {
                $data = self::alias('a')
                    ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                    ->join('xs_recommend as b on a.id = b.nid')
                    ->where($where)
                    ->limit(self::RECOMMEND_COUNT)
                    ->order($order)
                    ->select();

                if($data) {
                    $redis->pipeline();
                    foreach ($data as $v) {
                        $redis->sadd(self::randRecommendCacheKey(), serialize($v));
                    }
                    $redis->EXPIRE(self::randRecommendCacheKey(), self::recommendCaCheTimeOut());
                    $redis->exec();

                    $data = $redis->srandmember(self::randRecommendCacheKey(), self::RECOMMEND_NUM);


                    foreach ($data as $k => $v) {
                        $data[$k] = unserialize($v);
                    }
                }

            }else{
                foreach ($data as $k => $v) {
                    $data[$k] = unserialize($v);
                }

            }
        }else {
            $data = $redis->srandmember(self::randRecommendCacheKey($where['gender']), self::RECOMMEND_NUM);
            if (!$data) {
                $data = self::alias('a')
                    ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                    ->join('xs_recommend as b on a.id = b.nid')
                    ->where($where)
                    ->limit(self::RECOMMEND_COUNT)
                    ->order($order)
                    ->select();

                if($data) {
                    $redis->pipeline();
                    foreach ($data as $v) {
                        $redis->sadd(self::randRecommendCacheKey($where['gender']), serialize($v));
                    }
                    $redis->EXPIRE(self::randRecommendCacheKey($where['gender']),self::recommendCaCheTimeOut());
                    $redis->exec();

                    $data = $redis->srandmember(self::randRecommendCacheKey($where['gender']), self::RECOMMEND_NUM);

                    foreach ($data as $k => $v) {
                        $data[$k] = unserialize($v);
                    }
                }

            }else{
                foreach ($data as $k => $v) {
                    $data[$k] = unserialize($v);
                }
            }
        }

          return $data;

    }
    public function randRecommendCacheKey($gender=''){
        if($gender){
            return C('REDIS_PREFIX').'rand_recommend_list_'.$gender;
        }else{
            return  C('REDIS_PREFIX').'rand_recommend_list_all';
        }

    }



    //
    public function formatInfo($pathChapters,$label){

        $path_chapter = fetchIndex($pathChapters);
        $path_chapter=file_get_contents($path_chapter);
        $path_chapter = json_decode($path_chapter,true);
        if(empty($path_chapter['chapters'][$label])){
            return false;
        }


        if(preg_match('/\.\/data_center\/ZS\d?\//',$path_chapter['chapters'][$label]["link"])){
            $url=  preg_replace('/\.\/data_center\/ZS\d?\//',C('F_CDN'),$path_chapter['chapters'][$label]["link"]);
        }else{
            $url =  setImg($path_chapter['chapters'][$label]["link"]);
        }

         return $url;
    }




    public function formatList($data){

        $list = json_decode($data,true);
        if(!is_array($list['chapters'])){
            return false;
        }
        array_multisort(array_column($list['chapters'],'rename'),SORT_ASC,SORT_NUMERIC,$list['chapters']);


        foreach ($list['chapters'] as $k => &$v){
            if($v['unreadble']){
                $v['label'] = (string)$k;
                unset($v['link'],$v['unreadble'],$v['rename']);
            }else{
                unset($list['chapters'][$k]);
            }

        }


        return $list['chapters']?:[];

    }

    /**
     * @param $channel 获取详情推荐
     */

         public function getRecommendByMaCate($ma_cate,$id) {
             $redis = Datasource::getRedis('instance1');
             $where['status'] = self::STATUS_ON;
             $where['maCate'] = $ma_cate;
             $data = [];
             $order = 'updated desc';

             $data = $redis->srandmember(self::recommendCacheKeyByMaCate($ma_cate), self::RECOMMEND_NUM);


             if (!$data) {

                 $data = self::alias('a')
                     ->field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                     ->where($where)
                     ->limit(self::RECOMMEND_COUNT)
                     ->order($order)
                     ->select();

                 if ($data) {
                     $data = array_map('callbackImg', $data);;
                     $data = array_map(function ($var)
                     {
                         $cate = D('Admin/Cates')->getCateById($var['maCate']);
                         $majorCate = $cate['name']?:$var['majorCate'];
                         $var['majorCate'] = $majorCate;
                         return $var;
                     },$data);

                 }

                 if($data) {
                     $redis->pipeline();
                     foreach ($data as $v) {
                         $redis->sadd(self::recommendCacheKeyByMaCate($ma_cate), serialize($v));
                     }
                     $redis->EXPIRE(self::recommendCacheKeyByMaCate($ma_cate),self::recommendCaCheTimeOut());
                     $redis->exec();

                     $data = $redis->srandmember(self::recommendCacheKeyByMaCate($ma_cate), self::RECOMMEND_NUM);

                     $data_res = [];

                     foreach ($data as $k => $v) {
                         $data[$k] = unserialize($v);

                         if($data[$k]['id'] == $id ){
                             unset($data[$k]);
                         }else{
                             array_push($data_res,$data[$k]);
                         }
                     }

                 }


             } else {
                 $data_res = [];
                 foreach ($data as $k => $v) {
                     $data[$k] = unserialize($v);

                     if($data[$k]['id'] == $id ){
                         unset($data[$k]);
                     }else{
                         array_push($data_res,$data[$k]);
                     }
                 }
             }

             return $data_res;

         }


         public function getRecommend($channel){
         $redis = Datasource::getRedis('instance1');
         $where['a.status'] = self::STATUS_ON;
         $where['b.status'] = self::STATUS_ON;
         $data = [];
         $order = 'rating desc,updated desc';
         if($channel){
             $where_data['status'] = self::STATUS_ON;
             $where_data['name'] = $channel;
             $channel_model = D('Admin/SysChannel');
             $channel_id = $channel_model->where($where_data)->field('id')->find();
             if($channel_id) {
                 $data = $redis->srandmember(self::recommendCacheKey($channel_id['id']), self::RECOMMEND_NUM);

                 if (!$data) {
                     $where['chn_id'] = ['like','%'.$channel_id['id'].'%'];

                     $data = self::alias('a')
                         ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                         ->join('xs_recommend as b on a.id = b.nid')
                         ->where($where)
                         ->limit(self::RECOMMEND_COUNT)
                         ->order($order)
                         ->select();

                     if ($data) {
                         $data = array_map('callbackImg', $data);;
                         $data = array_map(function ($var)
                         {
                             $cate = D('Admin/Cates')->getCateById($var['maCate']);
                             $majorCate = $cate['name']?:$var['majorCate'];
                             $var['majorCate'] = $majorCate;
                             return $var;
                         },$data);

                     }

                     if($data) {
                         $redis->pipeline();
                         foreach ($data as $v) {
                             $redis->sadd(self::recommendCacheKey($channel_id['id']), serialize($v));
                         }
                         $redis->EXPIRE(self::recommendCacheKey($channel_id['id']),self::recommendCaCheTimeOut());
                         $redis->exec();

                         $data = $redis->srandmember(self::recommendCacheKey($channel_id['id']), self::RECOMMEND_NUM);

                         foreach ($data as $k => $v) {
                             $data[$k] = unserialize($v);
                         }

                     }


                 } else {
                     foreach ($data as $k => $v) {
                         $data[$k] = unserialize($v);
                     }
                 }
             }

         }else{
             $data = $redis->srandmember(self::recommendCacheKey(),self::RECOMMEND_NUM);

             if(!$data){

                 $data = self::alias('a')
                     ->field('a.id,a.title,a.cover,a.author,a.longIntro,a.wordCount,a.gender,a.over,a.score,a.serializeWordCount,a.latelyFollower,a.retentionRatio,a.tags,a.isfree,a.majorCate,a.maCate,a.lastChapter,a.updated')
                     ->join('xs_recommend as b on a.id = b.nid')
                     ->where($where)
                     ->limit(self::RECOMMEND_COUNT)
                     ->order($order)
                     ->select();

                 if ($data) {
                     $data = array_map('callbackImg', $data);
                     $data = array_map(function ($var)
                     {
                         $cate = D('Admin/Cates')->getCateById($var['majorCate']);
                         $majorCate = $cate['name']?:$var['majorCate'];
                         $var['majorCate'] = $majorCate;
                         return $var;
                     },$data);
                 }

                 if($data) {
                     $redis->pipeline();
                     foreach ($data as $v) {
                         $redis->sadd(self::recommendCacheKey(), serialize($v));
                     }
                     $redis->EXPIRE(self::recommendCacheKey(),self::recommendCaCheTimeOut());
                     $redis->exec();
                     $data = $redis->srandmember(self::recommendCacheKey(), self::RECOMMEND_NUM);

                     foreach ($data as $k => $v) {
                         $data[$k] = unserialize($v);
                     }

                 }

             }else{
                 foreach ($data as $k => $v) {
                     $data[$k] = unserialize($v);
                 }

             }


         }
         return $data;
     }

     public function recommendCacheKeyByMaCate($ma_cate){
         return  C('REDIS_PREFIX').'recommend_list_macate_'.$ma_cate;
     }

     public function recommendCaCheTimeOut(){
         return (strtotime('tomorrow')-time())+3630;
     }

     public  function recommendCacheKey($channel=''){
            if($channel){
                return  C('REDIS_PREFIX').'recommend_list_'.$channel;
            }else{
                return  C('REDIS_PREFIX').'recommend_list_all';
            }
     }

    /**
     * @param $id
     * @return mixed
     */
    public function getDetailById($id,$save_path = ''){

        $data = S(self::detailCacheKey($id));

        if(!$data) {
            $where['id'] = $id;
            $where['status'] = self::STATUS_ON;
            $data = self::where($where)
                ->field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,pathChapters,lastChapter,updated')
                ->find();
            if($data){
                $data['cover'] = setImg($data['cover']);
                $data['score'] = sprintf("%s",intval($data['score']));
                $cate = D('Admin/Cates')->getCateById($data['maCate']);
                $data['majorCate'] = $cate['name']?:$data['majorCate'];

                S(self::detailCacheKey($id),serialize($data));
                if(!$save_path){
                    unset($data['pathChapters']);
                }
            }
        }else{
            $data = unserialize($data);
            if(!$save_path) {
                unset($data['pathChapters']);
            }
        }

        return $data;
    }

    public  function clearDetailCache($id){
        S(self::detailCacheKey($id),null);
    }
    public function detailCacheKey($id){
          return 'detail_'.$id;
    }


    /**
     * @param int $n_id  Newcharts
     * @param int $page
     * @param int $size
     */
    public function getHDataByNid($n_id = 'new',$page = 1,$size = 6){

        $order = 'weight desc,create_at desc';
        $redis = Datasource::getRedis('instance1');
        $start = ($page-1)*$size;
        $end   = ($start+$size)-1;

        $where['type'] = $n_id;
        $where['html_show'] = 1;
        $where['status'] = self::STATUS_ON;

        $data = $redis->lrange(self::HNovelsCahceKeyByNid($n_id),$start,$end);
        $cache_len = $redis->llen(self::HNovelsCahceKeyByNid($n_id));

        if(count($data) != $size){
            $data = [];
        }

        if(!$data) {
            $data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                ->where($where)
                ->order($order)
                ->limit($start, $size)
                ->select();
            if ($data) {
                $data = array_map('callbackImg', $data);
                $data = array_map(function ($var)
                {
                    $cate = D('Admin/Cates')->getCateById($var['maCate']);
                    $majorCate = $cate['name']?:$var['majorCate'];
                    $var['majorCate'] = $majorCate;
                    return $var;
                },$data);
            }

            if(!$cache_len && $data) {
                //存储到缓存
                if ($redis->set(self::HNovelsCahceKeyByNid($n_id).'_lock', 1, ['nx', 'ex' => 180])) {
                    $cache_data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                        ->where($where)
                        ->order($order)
                        ->limit(self::CACHE_NUM)
                        ->select();


                    if ($cache_data) {
                        $cache_data = array_map('callbackImg', $cache_data);
                        $cache_data = array_map(function ($var)
                        {
                            $cate = D('Admin/Cates')->getCateById($var['maCate']);
                            $majorCate = $cate['name']?:$var['majorCate'];
                            $var['majorCate'] = $majorCate;
                            return $var;
                        },$cache_data);
                    }

                    $redis->pipeline();

                    foreach ($cache_data as $k => $v) {
                        $redis->rpush(self::HNovelsCahceKeyByNid($n_id), serialize($v));
                    }
                    $redis->EXPIRE(self::HNovelsCahceKeyByNid($n_id), self::CATES_TIMEOUT + 3300);
                    $redis->exec();

                    $redis->del(self::HNovelsCahceKeyByNid($n_id).'_lock');
                }
            }

        }else{
            foreach ($data as $k => $v){
                $data[$k] = unserialize($v);
            }

        }

        return $data;

    }



    public function getDataByNid($n_id = 'new',$page = 1,$size = 6){

        $order = 'weight desc,latelyFollower desc';
        $redis = Datasource::getRedis('instance1');
        $start = ($page-1)*$size;
        $end   = ($start+$size)-1;

        $where['type'] = $n_id;
        $where['html_show'] = 0;
        $where['status'] = self::STATUS_ON;

        $data = $redis->lrange(self::NovelsCahceKeyByNid($n_id),$start,$end);
        $cache_len = $redis->llen(self::NovelsCahceKeyByNid($n_id));

        if(count($data) != $size){
            $data = [];
        }

        if(!$data) {
            $data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                ->where($where)
                ->order($order)
                ->limit($start, $size)
                ->select();
            if ($data) {
                $data = array_map('callbackImg', $data);
                $data = array_map(function ($var)
                {
                    $cate = D('Admin/Cates')->getCateById($var['maCate']);
                    $majorCate = $cate['name']?:$var['majorCate'];
                    $var['majorCate'] = $majorCate;
                    return $var;
                },$data);
            }

            if(!$cache_len && $data) {
                //存储到缓存
                if ($redis->set(self::NovelsCahceKeyByNid($n_id).'_lock', 1, ['nx', 'ex' => 180])) {
                    $cache_data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                        ->where($where)
                        ->order($order)
                        ->limit(self::CACHE_NUM)
                        ->select();


                    if ($cache_data) {
                        $cache_data = array_map('callbackImg', $cache_data);
                        $cache_data = array_map(function ($var)
                        {
                            $cate = D('Admin/Cates')->getCateById($var['maCate']);
                            $majorCate = $cate['name']?:$var['majorCate'];
                            $var['majorCate'] = $majorCate;
                            return $var;
                        },$cache_data);
                    }

                    $redis->pipeline();

                    foreach ($cache_data as $k => $v) {
                        $redis->rpush(self::NovelsCahceKeyByNid($n_id), serialize($v));
                    }
                    $redis->EXPIRE(self::NovelsCahceKeyByNid($n_id), self::CATES_TIMEOUT + 2400);
                    $redis->exec();

                    $redis->del(self::NovelsCahceKeyByNid($n_id).'_lock');
                }
            }

        }else{
            foreach ($data as $k => $v){
                $data[$k] = unserialize($v);
            }

        }

            return $data;

    }




    /**
     * @param int $m_id 主分类ID
     */
    public  function getDataByCates($m_id = 0,$page = 1,$size = 6){

        $where['status'] = self::STATUS_ON;
        $order = 'weight desc,latelyFollower desc';
        $redis = Datasource::getRedis('instance1');
        $start = ($page-1)*$size;
        $end   = ($start+$size)-1;

        if($m_id){

            $where['maCate'] = $m_id;
            $data = $redis->lrange(self::NovelsCacheKeyByMid($m_id),$start,$end);
            $cache_len = $redis->llen(self::NovelsCacheKeyByMid($m_id));

            if(count($data) != $size){
                $data = [];
            }

            if(!$data) {
                $data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                    ->where($where)
                    ->order($order)
                    ->limit($start, $size)
                    ->select();
                if ($data) {
                    $data = array_map('callbackImg', $data);
                }


                if(!$cache_len) {
                         //存储到缓存
                    if ($redis->set(self::NovelsCacheKeyByMid($m_id).'_lock', 1, ['nx', 'ex' => 180])){

                            $cache_data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,lastChapter,updated')
                                ->where($where)
                                ->order($order)
                                ->limit(self::CACHE_NUM)
                                ->select();


                            if ($cache_data) {
                                $cache_data = array_map('callbackImg', $cache_data);
                            }

                            $redis->pipeline();

                            foreach ($cache_data as $k => $v) {
                                $redis->rpush(self::NovelsCacheKeyByMid($m_id), serialize($v));
                            }
                            $redis->EXPIRE(self::NovelsCacheKeyByMid($m_id), self::CATES_TIMEOUT + 1600);
                            $redis->exec();
                            $redis->del(self::NovelsCacheKeyByMid($m_id).'_lock');
                    }
                }

            }else{
                foreach ($data as $k => $v){
                    $data[$k] = unserialize($v);
                }
            }



        }else{

            $data = $redis->lrange(self::NovelsCacheKey(),$start,$end);

            $cache_len = $redis->llen(self::NovelsCacheKey());

            if(count($data) != $size){
                $data = [];
            }

            if(!$data) {
                $data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                    ->where($where)
                    ->order($order)
                    ->limit($start,$size)
                    ->select();


                if ($data) {
                    $data = array_map('callbackImg', $data);
                }

                if(!$cache_len) {
                    //存储到缓存
                    if ($redis->set(self::NovelsCacheKey() . '_lock', 1, ['nx', 'ex' => 180])) {
                        $cache_data = self::field('id,title,cover,author,longIntro,wordCount,gender,over,score,serializeWordCount,latelyFollower,retentionRatio,tags,isfree,majorCate,maCate,lastChapter,updated')
                            ->where($where)
                            ->order($order)
                            ->limit(self::CACHE_NUM)
                            ->select();


                        if ($cache_data) {
                            $cache_data = array_map('callbackImg', $cache_data);
                        }
                        $redis->pipeline();

                        foreach ($cache_data as $k => $v) {
                            $redis->rpush(self::NovelsCacheKey(), serialize($v));
                        }

                        $redis->EXPIRE(self::NovelsCacheKey(), self::CATES_TIMEOUT + 600);
                        $redis->exec();
                        $redis->del(self::NovelsCacheKey() . '_lock');
                    }
                }

            }else{
                foreach ($data as $k => $v){
                    $data[$k] = unserialize($v);
                }
            }

        }

        return $data;

    }
    public function HNovelsCahceKeyByNid($n_id){
        return  C('REDIS_PREFIX').'h_novels_list_newcharts_'.$n_id;
    }
    public function NovelsCahceKeyByNid($n_id){
        return  C('REDIS_PREFIX').'novels_list_newcharts_'.$n_id;
    }
    public function NovelsCacheKeyByMid($m_id){
        return  C('REDIS_PREFIX').'novels_list_'.$m_id;
    }
    /**  novel全部缓存key
     * @return string
     */
    public function NovelsCacheKey(){
        return  C('REDIS_PREFIX').'novels_list_all';
    }
    public function createChapterIndex($path){
        return $path.md5(uniqid(true).salt(2)).'.json';
    }
        //_____________________________
    public function getId($_id)
    {
    	return S($this->getMappingKey($_id)) ? : 0;
    }

    public function mapping()
    {
    	$all = $this->getField("id, _id", true);
    	foreach ($all as $id => $_id)
    	{
    		$key = $this->getMappingKey($_id);
    		S($key, $id);
    	}
    }

    public function getMappingKey($_id)
    {
    	return "mapping_id" . $_id;
    }

    public function dataFormat(array $data)
    {
        $cates = D('Admin/Cates')->getData();
        $over = $this->over;
        $openlevel = $this->openlevel;
        $gender = $this->gender;
        $info = [];
        $chapterModel = D('Admin/Chapters');
        foreach ($data as $k => $val)
        {
            $lastChapterInfo = $chapterModel->getCache($val['_id'], $val['lastChapter']);
            $isPayChapterInfo = $chapterModel->getCache($val['_id'], $val['isPayChapter']);
            $info[] = [
                '_id' => $val['_id'],
                'title' => $val['title'],
                'author' => $val['author'],
                'longIntro' => $val['longIntro'],
                'majorCate' => $cates[$val['majorCate']],
                'minorCate' => '',
                'cover' => !empty($val['cover']) ? (false !== strrpos($val['cover'], 'http') ? $val['cover']: cdn('ATTACH') . $val['cover']): "",
                'rating' => [
                    'count' => (int)$val['count'],
                    'score' => $val['score'],
                    'isEffect' => (bool)$val['isEffect'],
                ],
                'hasCopyright' => (bool)$val['hasCopyright'],
                'buytype' => (int)$val['buytype'],
                'contentType' => $val['contentType'],
                'allowMonthly' => (bool)$val['allowMonthly'],
                'latelyFollower' => (int)$val['latelyFollower'],
                'wordCount' => (int)$val['wordCount'],
                'serializeWordCount' => (int)$val['serializeWordCount'],
                'retentionRatio' => $val['retentionRatio'],
                'updated' => date("Y-m-d\TH:i:s\Z", $val['updated']), #2018-08-06T16:05:28.372Z
                'isSerial' => (bool)$val['isSerial'],
                'chaptersCount' => (int)$val['chaptersCount'],
                'lastChapter' => $lastChapterInfo[$val['lastChapter']]['title'],
                'gender' => [(string)$gender[$val['gender']]],
                'tags' => explode(',', $val['tags']),
                'cat' => '',
                'isPayChapter' => $isPayChapterInfo[$val['isPayChapter']]['title'],
                'openlevel' => (int)$val['openlevel'],
                'isfree' => (bool)$val['isfree'],
                'type' => $val['type'],
                'over' => (int)$val['over'],
            ];
        }  
        return $info;  
    }
}