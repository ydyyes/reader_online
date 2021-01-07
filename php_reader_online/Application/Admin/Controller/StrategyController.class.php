<?php

namespace Admin\Controller;

/**
 * Class StrategyController
 * @package Admin\Controller
 */
class StrategyController extends SystemController
{
    public $model = "strategy";

    /**
     * 展示渠道配置列表,首次点开自动生成列表
     */
    public function _before_index()
    {
        //渠道下的配置项不分页,所以把每页的页数调大
        C('PAGE_LISTROWS', 100);
        $channel_id = I('get.channel_id');
        $channel_name = I('get.channel_name');
        $res = D($this->model)->where(['channel_id'=>$channel_id])->select();
        D($this->model)->init($channel_id, $channel_name);
    }
    
    /**
     * 检查相同渠道下的配置项是否存在
     */
    public function _before_insert()
    {
        $msg['channel_id'] = I('post.channel_id');
        $msg['name'] = I('post.name');
        $res = D($this->model)->where($msg)->find();
        if(!empty($res))
            $this->error('此渠道下的配置项已经存在');
    }
    
    /**
     * 添加配置项后重建渠道配置项的缓存
     */
    public function _after_insert()
    {
        $channel_name = I('post.channel_name');
        D($this->model)->createStrategyCache($channel_name);
    }
    
    /**
     * 更新后重建渠道配置项的缓存
     */
    public function save()
    {
        $msg = I('post.');
        $ids = array_keys($msg);
        foreach($ids as $id)
        {
            $oldval = D($this->model)->where(['id'=>$id])->getField('value');
            if($oldval == $msg[$id])
                continue;
            $data = ['id'=>$id,'value'=>$msg[$id], 'update_time'=>time()];
            if(D($this->model)->create($data))
                D($this->model)->save();
        }
        $channel_name = I('get.channel_name');
        D($this->model)->createStrategyCache($channel_name);
        $this->success('更新成功');
    }
    
    /**
     * 批量修改渠道配置
     * @date 2016年6月8日
     * @author zhanglei<firenzelei@163.com>
     */
    public function massedit()
    { 
        $data = D($this->model)->strategy_data;
        $allChannel = D("SysChannel")->order('id')->getField('id,name', true);
        $this->assign('allChannel', $allChannel);
        $this->assign('list', $data);
        $this->display();
    }
    
    /**
     * 批量修改渠道配置
     * 修改后重建相应渠道的缓存
     */
    public function massupdate()
    {
        $msg = I('post.');
        foreach($msg as $k=>$v)
        {
            //只有input框填值的字段才能更新
            if(strlen($v)!==0 && $k!='channel')
                $dataArr[$k]=$v;
        }
        $channelArr = I('post.channel');
        if(empty($dataArr) || empty($channelArr))
            $this->error('渠道和配置项不能为空');
        foreach($channelArr as $channel)
        {
            $channel = explode(',', $channel);
            $channel_id = $channel[0];
            $channel_name = $channel[1];
            foreach($dataArr as $names=>$data)
            {
                $names = explode('--', $names);
                $name = $names[0];
                $cname = $names[1];
                $where = ['channel_id'=>$channel_id, 'name'=>$name];
                $is_exist = D($this->model)->where($where)->find();
                if(empty($is_exist))
                {
                    $res['channel_id'] = $channel_id;
                    $res['channel_name'] = $channel_name;
                    $res['name'] = $name;
                    $res['cname'] = $cname;
                    $res['value'] = $data;
                    $res['create_time'] = time();
                    $res['update_time'] = time();
                    D($this->model)->add($res);
                }else {
                    $save['value'] = $data;
                    $save['update_time'] = time();
                    D($this->model)->where($where)->save($save);
                }
            }
            //重建渠道配置项缓存
            D($this->model)->createStrategyCache($channel_name);
        }
        $fields = array_map(function($name){return substr($name, 0, strpos($name, '--'));}, array_keys($dataArr));
        $this->success(implode(',', $fields).'更新成功');
    }
}