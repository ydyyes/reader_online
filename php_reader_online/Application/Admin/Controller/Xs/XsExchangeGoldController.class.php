<?php
/**
 * User:Xxx
 */

namespace Admin\Controller\Xs;


use Admin\Controller\SystemController;

class XsExchangeGoldController extends SystemController
{
    public $model = "ExchangeGold";
    const PIC_PATH = 'exchange_gold/';

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['name']))
        {
            $map['name'] =['like','%'.$_search['name'].'%'];
        }

        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
    }


    public function uploader()
    {
        if(!IS_POST)
        {
            $this -> display();
            exit;
        }
        $msg = $this->uploadFile();
        $this->ajaxReturn($msg,'JSON');
    }


    /**
     * 上传文件的方法
     */
    protected function uploadFile()
    {
        $file = $_FILES['file'];
        try {
            if (is_uploaded_file($file['tmp_name']));
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
                $extArr = ['png','jpg'];
                if (!in_array($ext,$extArr))
                {
                    throw new \Exception("只支持png,jpg");
                }
                $filename = $file['name'];
                //将文件移动到制定位置。
                $dir = get_cdn_share_dir('pic') . self::PIC_PATH;
                $imgName = recreate_img_name(substr(md5(time().uniqid()), 8, 16).".".$ext);
                $path = pathinfo($imgName, PATHINFO_DIRNAME);
                if(!is_dir($dir.$path))
                {
                    mkdir($dir.$path, 0777, true);
                }

                $result = move_uploaded_file($file['tmp_name'], $dir . $imgName);
                if (!$result)
                {
                    throw new \Exception("上传失败");
                }
                $msg['pic'] = $filename;
                $msg['cover'] = self::PIC_PATH.$imgName;
                return $msg;
            }
        } catch (\Exception $e) {
            \Think\Log::write(var_export($_POST, true), \Think\Log::WARN);
            \Think\Log::write($e->getMessage(), \Think\Log::WARN);
            $this->error($e->getMessage());
        }
    }
    public function _after_update(){
        D($this->model)->ClearExchangeGoldListKay();
    }

    public function _after_insert(){
        D($this->model)->ClearExchangeGoldListKay();
    }

    public function _before(){
       $type = D($this->model)->type;
       $status = D($this->model)->status;

       $this->assign('type',$type);
       $this->assign('status',$status);
    }

}