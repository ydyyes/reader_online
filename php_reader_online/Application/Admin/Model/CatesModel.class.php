<?php
namespace Admin\Model;

/**
 * Class CatesModel
 * @package Admin\Model
 */
class CatesModel extends SystemModel
{
	protected $trueTableName = 'xs_cates';

	protected $_validate = array(
	    array('name','require','分类名称不能为空！'),
	);
	
	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
	);


	const STATUS_DEL = -1;
    const STATUS_OFF = 0;
	const STATUS_ON = 1;

	public $status = [
	    self::STATUS_DEL => '已删除',
	    self::STATUS_ON => '启用',
        self::STATUS_OFF => '禁用',
    ];
    public function getCateByName($name){
        $where['name'] = $name;
//        $where['status'] = CatesModel::STATUS_ON;
        $Cate = self::where($where)
            ->field('id,name')
            ->find();
        return $Cate;

    }
    /**
     * @param $id
     * @return \Think\Model
     */

	public function getCateById($id){
        $where['id'] = $id;
        $where['status'] = CatesModel::STATUS_ON;
        $Cate = self::where($where)
            ->field('id,name')
            ->find();
        return $Cate;
    }

    /**
     * @param $pid
     */

    public function getCatesByPid($pid){
        $where['pid'] = $pid;
        $where['status'] = CatesModel::STATUS_ON;
        $Cates = self::where($where)->getField('id,name', true);
        return $Cates;
    }

    /**
     *  获取分类数据
     */
	public function getCates(){
	    $cates_list = S(self::CatesKey());

	    if(!$cates_list){
	        $where['status'] = self::STATUS_ON;
	        $where['pid'] = 0;
	        $cates_list = self::where($where)->field('id,name')->select();

	       if($cates_list){
	             S(self::CatesKey(),serialize($cates_list));
           }

        }else{
            $cates_list = unserialize($cates_list);
        }
        return $cates_list;
    }
    public  function clearCates(){
        S(self::CatesKey(),null);
    }
    public  function CatesKey(){
	    return 'cates_list';
    }

	public function getData()
	{
	    $cachekey = $this->getCacheKey();
	    $data = S($cachekey);
	    return $data ? : [];
	}

	public function createCache()
	{
	    $data = $this->where(['status'=>self::STATUS_ON])->getField('id ,name', true);
	    
        $cachekey = $this->getCacheKey();
           
        S($cachekey, $data);
            
    }
		
	/**
	 * 获取缓存key
	 */
	public function getCacheKey()
	{
	    return "cate_list";
	}
}