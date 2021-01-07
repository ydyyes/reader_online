<?php
namespace Admin\Controller\Sys;
use Admin\Controller\SystemController;

class SysConfigController extends SystemController
{
	public $model = "SysConfig";
	public $not_allow_action = array("foreverdelete", "delete");
	
	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
	}
	
	protected function _before()
	{
		C("DEFAULT_FILTER", "trim");
	}
	
	public function setting()
	{
		$config = D($this->model)->where(["status"=>1])->select();
		$this->assign("config", $config)->display();
	}
	
	function save()
	{
		$post = I("post.");
		//检查参数格式是否正确
		$checkValue = $this->checkValue($post);
		if(!empty($checkValue['error']))
		    $this->error($checkValue['error']);

		$model = D($this->model);

		foreach ($post as $k=>$v)
		{
			$where = ["name"=>$k];
			$data  = ["value"=>is_array($v) ? json_encode($v) : $v];
			$data  = $model->create($data, \Think\MOdel::MODEL_UPDATE);
			$model->data($data)->where($where)->save();
		}

		$model->flushCache();
		$this->success('更新成功');
	}
	
	public function _after_insert()
	{
	    D($this->model)->flushCache();
	}

    /**
     * 检测参数值格式是否正确
     */
    public function checkValue($post)
    {
        //验证AFFILIATE_CHANNEL参数值是否正确
        $param = "AFFILIATE_CHANNEL";
        if(!array_key_exists($param, $post))
            return;
        $value = $post[$param];
        if($value=='[]')
            return;
        $preg = '/^{("([a-zA-Z0-9]+,?)+":"([0-9]+-?[0-9]*,?)+",?)*}$/';
        if(!preg_match($preg,$value))
            return ['error'=>$param.'格式不对或出现非法字符! 正确格式{"ym,aoc","3-22,33"}'];
        $value = json_decode($value, true);
        if(!empty($value))
        {
            foreach($value as  $v)
            {
                $res = [];
                foreach(explode(',', $v) as $vv)
                {
                    if(false!==stripos($vv, '-'))
                    {
                        list($start,$end) = explode('-', $vv);
                        if($start>$end)
                            return ['error'=>$param.'渠道为范围,但是大小颠倒!'];
                        $res = array_merge(range($start, $end), $res);
                    }else{
                        $res[] = intval($vv);
                    }
                }
                if($res != array_unique($res))
                    return ['error'=>$param.'渠道号重复!'];
            }
        }

        //验证CHANNEL_AFFILIATE参数值是否正确
        $param = "CHANNEL_AFFILIATE";
        $value = $post[$param];
        if($value=='[]')
            return;
        $preg = '/^{("([0-9]+-?[0-9]*,?)+[^,]":"([a-zA-Z0-9]+,?)+",?)*}$/';
        if(!preg_match($preg,$value))
            return ['error'=>$param.'格式不对或出现非法字符! 正确格式{"3-22,33":"ym,aoc"}'];
        $value = json_decode($value, true);
        if(!empty($value))
        {
            foreach($value as  $v=>$aff)
            {
                $res = [];
                foreach(explode(',', $v) as $vv)
                {
                    if(false!==stripos($vv, '-'))
                    {
                        list($start,$end) = explode('-', $vv);
                        if($start>$end)
                            return ['error'=>$param.'渠道为范围,但是大小颠倒!'];
                        $res = array_merge(range($start, $end), $res);
                    }else{
                        $res[] = intval($vv);
                    }
                }
                if($res != array_unique($res))
                    return ['error'=>$param.'渠道号重复!'];
            }
        }
    }
	
}