<?php
namespace Helper;

class Uploader
{
	public $type = 'image';
	public $uploader = null;
	public $config = null;
	
	function __construct()
	{
		$this->config = new \stdClass();
	}
	
	public function save()
	{	
		if(!IS_POST)
			$this->success('上传内容不能为空');
	
		if(!in_array($this->type, array('apk', 'screen', 'icon', 'image', 'doc', 'xls', 'xlsx')))
			$this->success('不允许的上传请求');
	
		if($this->type == 'apk')
		{
			$save_dir = 'apk';
			$this->config->exts = array('apk', 'amd');
			$this->config->maxSize = 1024*1000*300;
		}elseif (in_array($this->type, array('doc', 'xlsx', 'xls')))
		{
			$save_dir = 'doc';
			$this->config->exts = array('doc', 'xlsx', 'xls');
			$this->config->maxSize = 1024*1000*300;
		}elseif (in_array($this->type, array('pack', 'zip')))
		{
			$save_dir = $this->type;
			$this->config->exts = array('jar', 'so', 'pack', 'zip');
			$this->config->maxSize = 1024*1000*5;
		}else{
			$save_dir = $this->type;
			$this->config->exts = array('jpg', 'gif', 'png', 'jpeg');
			$this->config->maxSize = 1024*1000*5;
		}

		$upload_path = $this->upload_path_generator();
		$save_path = Helper("Url")->get_path($save_dir).$upload_path;

		$this->config->rootPath = Helper("Url")->get_path($save_dir);
		$this->config->savePath = $upload_path;
		$this->config->saveName = array('uniqid');
		$this->config->autoSub  = false;

		mkdir($save_path, 0777, true);
		
		$this->uploader = new \Think\Upload((array)$this->config);
		if(!$info = $this->uploader->upload())
			return $this->success($this->uploader->getError());
		
		$info = current($info);
		$FileName = $info['name'];
		$url = $info['savename'];
		$fileUrl = Helper("Url")->get_url($save_dir).$upload_path.$url;
		
		//添加到附件表
		try{
			$model = D("Attach");
			$model -> create(array("name"=>$FileName, "savename"=>$upload_path.$url), 1);
			$attach = $model->add();
		} catch (\Exception $e) {
			
		}
		
		return array("id"=>$attach, "saveName"=>$upload_path.$url, "fileName"=>$FileName, "filePath"=>$fileUrl);
	}
	
	/**
	 * 产生文件上传的文件目录
	 * 格式：
	 * 模块名/6位年月/2位日/两位随机数/随机文件名.扩展名
	 */
	protected function upload_path_generator()
	{
		$path = sprintf("%s\//%0.4s/", date("Ym/d"), md5(uniqid(date("His"))));
		$path = preg_replace('@[/\\\\]+@is', '/', $path);
		return $path;
	}
	
	protected function success($err='', $msg='', $FileName='')
	{
		$FileName = preg_replace("@['\"\(\)\[\]]+@is", '_', $FileName);
		echo json_encode(array('status'=>empty($err)?1:0, 'err'=>$err, 'msg'=>empty($err)?$msg:$err, 'filename'=>$FileName));
		exit;
	}
}