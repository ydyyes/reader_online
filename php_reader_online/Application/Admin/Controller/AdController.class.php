<?php

namespace Admin\Controller;

use Admin\Controller\SystemController;


/**
 * Class AdController
 * @package Admin\Controller
 */
class AdController extends SystemController
{
    const PIC_PATH = "xiaoshuo/";
    public $model = "ad";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['title']))
        {
            $map['title'] = ['like', '%'.$_search['title'].'%'];
        }
        if (isset($_search['location']))
        {
            $map['location'] = $_search['location'];
        }
        if (isset($_search['link']))
        {
            $map['link'] = $_search['link'];
        }
        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
    }

    public function _before()
    {
        $this->assign('status', D($this->model)->status);
        $this->assign('location', D($this->model)->location);
        $channelVersion = D('Admin/SysVersionChannel')->where(['status'=>1])->getField('id,channel_id,version_id', true);
        if (!empty($channelVersion))
        {
            $channels = D('Admin/SysChannel')->where(['id' => ['IN', array_column($channelVersion, 'channel_id')]])->getField('id,name', true);
            $versions = D('Admin/SysVersion')->where(['id' => ['IN', array_column($channelVersion, 'version_id')]])->getField('id,version_name', true);   
            $this->assign('channels', $channels);
            $this->assign('versions', $versions);
        }
        $this->assign('channelVersion', $channelVersion);
    }

    public function _before_insert()
    {
        $this->check();
    }

    public function _before_update()
    {
        $this->check();
        //删除当前缓存
        D($this->model)->beforeUpdateDel($_POST['id']);
    }

    public function check()
    {
        if (empty($_POST['chn_v_ids']))
        {
            $this->error("渠道版本至少填一个");
        }
        if (empty($_POST['img']))
        {
            $this->error("请上传图片");
        }
        $_POST['chn_v_ids'] = implode(',', $_POST['chn_v_ids']);
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
                $msg['name'] = $filename;
                $msg['img'] = self::PIC_PATH.$imgName;
                return $msg;
            }
        } catch (\Exception $e) {
            \Think\Log::write(var_export($_POST, true), \Think\Log::WARN);
            \Think\Log::write($e->getMessage(), \Think\Log::WARN);
            $this->error($e->getMessage());
        }
    }

    public function _after_insert()
    {
        $id = D($this->model)->where(['img'=>$_POST['img']])->getField('id');
        D($this->model)->createCache($id);
    }

    public function _after_update()
    {
        D($this->model)->createCache($_POST['id']);
    }
}