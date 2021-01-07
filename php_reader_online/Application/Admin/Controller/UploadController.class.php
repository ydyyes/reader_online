<?php 
namespace Admin\Controller;

/**
 * 编辑器上传组件
 * @since   1.0
 * @version 1.0
 * @date    2015年7月15日
 * @author  shuhai
 */
class UploadController extends SystemController
{
	//缩略图参数配置
	protected function thumb(&$upload){}
	
	public function save()
	{
		if(!IS_POST)
			$this->success('post null');
	
		$type = I('get.type');
		if(!in_array($type, array('image', 'file')))
			$this->success('不允许的上传请求');
	
		$upload = helper("Uploader");
		$upload->type = $type;
		$result = $upload->save();
		$this->success('', $result[0]["filepath"], $result[0]["filename"]);
	}
	
	protected function success($err='', $msg='', $FileName='')
	{
		$FileName = preg_replace("@['\"\(\)\[\]]+@is", '_', $FileName);
		echo json_encode(array('status'=>empty($err)?1:0, 'err'=>$err, 'msg'=>empty($err)?$msg:$err, 'filename'=>$FileName));
		exit;
	}
}