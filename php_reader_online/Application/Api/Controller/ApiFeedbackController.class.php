<?php
/**
 * author:liu.
 */

namespace Api\Controller;


use Admin\Model\FeedbackModel;

class ApiFeedbackController extends IndexController
{
    const  PIC_PATH = 'feedback';
    public function getDecryptData($data)
    {
        return $this->core($data);
    }

    public function getData()
    {
        $header = get_headers_info();
        $data = array_merge($header, $_POST);
        return $this->core($data);
    }

    protected function core($data)
    {
        $result = ['errno'=>0, 'data'=>[]];
        do {
            try {
                if (empty($data['uuid']))
                {
                    $result['errno'] = self::ERRNO_PARAM_INVALID;
                    break;
                }
                //注册
                $info = D('Admin/Users')->register($data['uuid']);
                if (empty($info))
                {
                    $result['data']['result'] = self::CODE_SERVER_ERR;
                    break;
                }
                //检查参数
               $res = $this->check($data);

                if(!$res){
                    $result['errno'] = self::ERRNO_PARAM_INVALID;
                    break;
                }
                $upload = $this->uploadFile();
                if(!$upload){
                    $result['data']['result'] = self::CODE_SERVER_ERR;
                    break;
                }

                $res_data['content'] = $data['content'];
                $res_data['cover'] = $upload['cover'];


                 $feedback_model = new FeedbackModel();
                 $feedback_model ->add($res_data);

                $result['data']['result'] = self::CODE_SUCC;

            } catch (\Exception $e) {
            }

        } while(false);

        return $result;
    }

    private function check($data){
      
        if( empty($data['content']) || strlen($data['content'] ) > 500){
            return false;
        }
            return true;
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