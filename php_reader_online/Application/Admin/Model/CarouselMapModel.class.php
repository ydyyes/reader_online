<?php
namespace Admin\Model;

use Common\Controller\Datasource;

/**
 * Class CarouselMapModel
 * @package Admin\Model
 */
class CarouselMapModel extends SystemModel
{
	protected $trueTableName = 'xs_carousel_map';

	protected $_validate = array(
        array('name','require','name不能为空！'),
        array('type','require','类型必选！'),
        array('fid','require','广告或书籍ID必填！'),
	);
    protected $_map = array(
        'inner' =>'local_inner',

    );

    const STATUS_OFF = 0;
	const STATUS_ON = 1;

	const TYPE_AD = 1;
	const TYPE_BOOK = 2;

	const INNER_1 = 1;
    const INNER_2 = 2;
    const INNER_3 = 3;

    public $inner = [
        self::INNER_1 => '福利中心',
        self::INNER_2 => '兑换金币',
        self::INNER_3 => '邀请好友',
    ];


	public $status = [
	    self::STATUS_ON => '上架',
        self::STATUS_OFF => '下架',
    ];

    public $types = [
        self::TYPE_AD => '广告',
        self::TYPE_BOOK => '小说',
    ];

    public function getBannerByChannel($channel){
           $id = D('Admin/SysChannel')
                ->where(['name' => $channel])
                ->getField('id');


           if($id) {
               $info = self::getBannerChannel($id);
           }else{
               $info = self::getBanner();
           }
           $info  = $info?:[];

        return $info;

    }

    public function getBannerChannel($id){
        $redis = Datasource::getRedis('instance1');
        $info = $redis->get(self::bannerChannelCacheKey($id));
        $info =[];
        if(!$info){
            $fields = ['id', 'name', 'type', 'fid', 'img','local_inner'];
            $data = $this->where(['status'=>self::STATUS_ON,'chn_id' => ['like','%'.$id.',%']])
                ->field($fields)
                ->order('weight desc')
                ->select();

            $adModel = D('Admin/Ad');
            $novelModel = D('Admin/Novels');
            if ($data)
            {
                foreach ($data as $k => $val)
                {
                    $val['img'] =  !empty($val['img']) ? cdn('ATTACH') . $val['img'] : "";
                    $row = [
                        'id' => $val['id'],
                        'name' => $val['name'],
                        'fid' => $val['fid'],
                        'img' => $val['img'],
                        'inner' => $val['inner']?:'0'
                    ];

                    $tmp = [];
                    if ($val['type'] == self::TYPE_AD)
                    {
                        $tmp = $adModel->where(['id'=>$val['fid']])->field(['title','link','location','img','update_at'])->find();
                        $tmp['cover'] = !empty($tmp['img']) ? cdn('ATTACH') . $tmp['img'] : "";
                        $tmp['update'] = date('Y-m-d', $tmp['update_at']);
                        unset($tmp['update_at'], $tmp['img']);
                        $tmp['type'] = "ad";
                    } else{
                        $id = $novelModel->where(['id'=>$val['fid']])->getField('id');
                        $tmp = ['id' => $id, 'type'=>'book'];
                    }
                    $row = array_merge($row, $tmp);
                    $info[$k] = $row;
                }

                    $redis->set(self::bannerChannelCacheKey($id),serialize($info));

            }else{
                  $info = self::getBanner();
            }

        }else{
            $info = unserialize($info);
        }

        $info = $info?:[];
        return $info;

    }

    public function getBanner(){
        $info = S(self::bannerCacheKey());
        if(!$info){
            $fields = ['id', 'name', 'type', 'fid', 'img','local_inner'];
            $data = $this->where(['status'=>self::STATUS_ON])
                ->field($fields)
                ->order('weight desc')
                ->select();

            $adModel = D('Admin/Ad');
            $novelModel = D('Admin/Novels');
            if ($data)
            {
                foreach ($data as $k => $val)
                {
                    $val['img'] =  !empty($val['img']) ? cdn('ATTACH') . $val['img'] : "";
                    $row = [
                        'id' => $val['id'],
                        'name' => $val['name'],
                        'fid' => $val['fid'],
                        'img' => $val['img'],
                        'inner' => $val['inner']?:'0'
                    ];

                    $tmp = [];
                    if ($val['type'] == self::TYPE_AD)
                    {
                        $tmp = $adModel->where(['id'=>$val['fid']])->field(['title','link','location','img','update_at'])->find();
                        $tmp['cover'] = !empty($tmp['img']) ? cdn('ATTACH') . $tmp['img'] : "";
                        $tmp['update'] = date('Y-m-d', $tmp['update_at']);
                        unset($tmp['update_at'], $tmp['img']);
                        $tmp['type'] = "ad";
                    } else{
                        $id = $novelModel->where(['id'=>$val['fid']])->getField('id');
                        $tmp = ['id' => $id, 'type'=>'book'];
                    }
                    $row = array_merge($row, $tmp);
                    $info[$k] = $row;
                }
                if($info){
                    S(self::bannerCacheKey(),serialize($info));
                }
            }

        }else{
            $info = unserialize($info);
        }
         $info = $info?:[];
            return $info;
    }

    public function bannerChannelCacheKey($id){
             return C('REDIS_PREFIX').'banner_key_'.$id;
    }
    public function clearBannerCache(){
        $redis = Datasource::getRedis('instance1');
        $banner_list = $redis->keys(C('REDIS_PREFIX').'banner_key_*');
        foreach ($banner_list as $v){
               $redis->del($v);
        }

    }

//    public function clearBannerCache(){
//            S(self::bannerCacheKey(),null);
//    }
    public function bannerCacheKey(){
        return 'banner_key_all';
    }
    //______________________________

    public function getCache()
    {
        $data = S($this->getCacheKey());
        return $data ? $data : [];
    }

	public function createCache()
	{
        $fields = ['id', 'name', 'type', 'fid', 'img'];
        $data = $this->where(['status'=>self::STATUS_ON])->field($fields)->order('weight desc')->select();
        $adModel = D('Admin/Ad');
        $novelModel = D('Admin/Novels');
        $info = [];
        if ($data)
        {
            foreach ($data as $k => $val)
            {
                $val['img'] =  !empty($val['img']) ? cdn('ATTACH') . $val['img'] : "";
                $row = [
                    'id' => $val['id'],
                    'name' => $val['name'],
                    'fid' => $val['fid'],
                    'img' => $val['img'],
                ];

                $tmp = [];
                if ($val['type'] == self::TYPE_AD)
                {
                    $tmp = $adModel->where(['id'=>$val['fid']])->field(['title','link','location','img','update_at'])->find();
                    $tmp['cover'] = !empty($tmp['img']) ? cdn('ATTACH') . $tmp['img'] : "";
                    $tmp['update'] = date('Y-m-d', $tmp['update_at']);
                    unset($tmp['update_at'], $tmp['img']);
                    $tmp['type'] = "ad";
                } elseif ($val['type'] == self::TYPE_BOOK) {
                    $_id = $novelModel->where(['id'=>$val['fid']])->getField('_id');
                    $tmp = ['_id' => $_id, 'type'=>'book'];
                } elseif ($val['type'] == self::TYPE_GAME) {
                    $tmp = D('Admin/Games')->where(['id'=>$val['fid']])->field(['name', 'img', 'link', 'update_at'])->find();
                    $tmp['title'] = $tmp['name'];
                    $tmp['cover'] = !empty($tmp['img']) ? cdn('ATTACH') . $tmp['img'] : "";
                    $tmp['update'] = date('Y-m-d', $tmp['update_at']);
                    unset($tmp['update_at'], $tmp['img'], $tmp['name']);
                    $tmp['type'] = "game";
                }
                $row = array_merge($row, $tmp);
                $info[$k] = $row;
            }
        }
        S($this->getCacheKey(), $info);
    }
		
	/**
	 * 获取缓存key
	 */
	public function getCacheKey()
	{
	    return "carousel_map";
	}

    /**
     * 小说／广告：只同步下架，不同步上架
     * @param $id
     */
    public function syncCarouselMap($id)
    {
        $count = $this->where(['fid'=>$id, 'status'=>CarouselMapModel::STATUS_ON])->count();
        if ($count > 0)
        {
            $this->where(['fid'=>$id])->save(['status'=>CarouselMapModel::STATUS_OFF, 'update_at'=>time()]);
            $this->createCache();
        }
    }
}