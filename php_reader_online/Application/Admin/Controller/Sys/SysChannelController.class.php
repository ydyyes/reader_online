<?php
namespace Admin\Controller\Sys;
use Admin\Controller\SystemController;

class SysChannelController extends SystemController
{
	public $model = "SysChannel";
	public $not_allow_action = ["foreverdelete", "delete"];
	
	public function _filter(&$map)
	{
		$_search = search_map();
		$map = !empty($_search) ? array_merge($_search, $map) : $map;
		$map['type'] = 2;
	}
	
    public function _before_insert()
    {
        $this->checkValid();
        //生成渠道的唯一标识
        $_POST['hash'] = hashCode32(trim($_POST['name']));
    }

    public function _before_update()
    {
        $this->checkValid();
        $_POST['hash'] = hashCode32(trim($_POST['name']));
    }
	
	public function _after_insert()
	{
		S('channelCache',null);
		D($this->model)->createChannelList();
		$id = D($this->model)->where(['name'=>trim($_POST['name'])])->getField('id');
		if ($id > 0)
		{
			$this->addChannel($id);
		}
	}
	
	public function _after_update()
	{
		S('channelCache',null);
		D($this->model)->createChannelList();
	}

    public function checkValid()
    {
        if ($_POST['ratio_sharing'] < 0 || $_POST['ratio_sharing'] > 100)
        {
            $this->error("渠道分成输入无效！请填写0-100之间(包含0和100)的数字！");
        }
    }

    public function addChannel($chid){
    	$recommend = D('Admin/Recommend');
    	$data = $recommend->getField('id, chn_id', true);
    	foreach ($data as $id => $chn_id){
    		if (empty($chn_id)){
    			$chn_id = "," . $chid . ",";
    		} else {
    			$chn_id .= $chid . ",";
    		}
    		$recommend->where(['id'=>$id])->save(['chn_id'=>$chn_id]);
    	}
    }
}
