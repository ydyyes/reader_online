<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


use Admin\Model\FeedbackModel;
use Common\Controller\Datasource;

class FeecbackController extends BaseController
{
    const  PIC_PATH = 'feedback';
    protected $login = 1;
    public function create(){

        $upload = $this->uploadFile();
        $uid = $this->userinfo['id'];
        if(!$uid){
            $this->returnResult(300108, '');
        }

        $res_data['uid'] = $uid;
        $res_data['content'] = htmlspecialchars($this->parm['content']);
        $res_data['cover'] = (!empty($upload['cover']))?$upload['cover']:'';
        $res_data['model'] = $this->header['model']?:'';
        $res_data['vcode'] = $this->header['vcode']?:'';

        $feedback_model = new FeedbackModel();
        $feedback_model ->add($res_data);

        $this->returnResult(200,'',[]);

    }
    protected function _check_para($data)
    {
        if( mb_strlen($data['content'], 'utf8') <= 10 || mb_strlen($data['content'], 'utf8') >= 200){
             $this->returnResult(400109);
        }
    }
    private function uploadFile()
    {

        $file = $_FILES['file'];
        $flag = 0;

        $path = self::PIC_PATH;
        $extArr = ['png','jpg'];

        try {
            if (!empty($file) && is_uploaded_file($file['tmp_name']));
            {
                if ($file['error'] > 0)
                {
                    if ($file['error'] == UPLOAD_ERR_INI_SIZE || $file['error'] == UPLOAD_ERR_FORM_SIZE)
                    {
                        throw new \Exception("文件太大，请修改上传尺寸配置");
                    }
                    throw new \Exception("上传失败");
                }
                $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
                if (!in_array($ext,$extArr))
                {
                    throw new \Exception("只支持".implode(',', $extArr));
                }
                $filename = $file['name'];
                $dir = get_cdn_share_dir('pic') . $path;


                $uniq = md5(time().uniqid());
                $nextName = recreate_img_name(substr($uniq, 8, 16).".".$ext);
                $msg['cover'] = $path.DIRECTORY_SEPARATOR.$nextName;

                $path2 = pathinfo($nextName, PATHINFO_DIRNAME);

                if(!is_dir($dir.DIRECTORY_SEPARATOR.$path2))
                {
                    mkdir($dir.DIRECTORY_SEPARATOR.$path2, 0777, true);
                }

                $result = move_uploaded_file($file['tmp_name'], $dir .DIRECTORY_SEPARATOR. $nextName);
                if (!$result)
                {
                    return false;
                }
                return $msg;
            }
            return false;
        } catch (\Exception $e) {
            \Think\Log::write(var_export($_POST, true), \Think\Log::WARN);
            \Think\Log::write($e->getMessage(), \Think\Log::WARN);
            return false;
        }
    }


}