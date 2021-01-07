<?php

namespace Admin\Controller;

use Admin\Controller\SystemController;
use Admin\Model\CarouselMapModel;
use Admin\Model\AdModel;
use Admin\Model\NovelsModel;

/**
 * Class CarouselMapController
 * @package Admin\Controller
 */
class CarouselMapController extends SystemController
{
    const PIC_PATH = "xiaoshuo/";
    public $model = "carousel_map";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['name']))
        {
            $map['name'] = $_search['name'];
        }
        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
        if (isset($_search['type']))
        {
            $map['type'] = $_search['type'];
        }
    }

    public function _before()
    {
        $inner = D($this->model)->inner;
        $channels = D('Admin/SysChannel')->getField('id, name', true);

        $this->assign('inner',$inner);
        $this->assign('channels', $channels);
        $this->assign('status', D($this->model)->status);
        $this->assign('types', D($this->model)->types);
    }

    public function _before_insert()
    {


        $this->check();
        $_POST['create_at'] = $_POST['update_at'] = time();
    }

    public function _before_update()
    {

        $this->check();
        $_POST['update_at'] = time();
    }

    public function check()
    {
        if (empty($_POST['chn_id']))
        {
            $this->error('渠道必选');
        }
        $_POST['chn_id'] = ',' . trim(implode(',', $_POST['chn_id']), ',') . ',';
        $_POST = array_map('trim', $_POST);
        if ($_POST['weight'] < 0)
        {
            $this->error('排序请用正整数');
        }
        $_POST['weight'] = intval($_POST['weight']);
        if (empty($_POST['type']) || empty($_POST['fid']))
        {
            $this->error("类型和对应类型的ID必填");
        }
        if ($_POST['type'] == CarouselMapModel::TYPE_AD)
        {
            $count = D('Admin/Ad')->where(['id'=>$_POST['fid'], 'status'=>AdModel::STATUS_ON])->count();
            if ($count <= 0)
            {
                $this->error("广告不存在或已下架");
            }
        }
        if ($_POST['type'] == CarouselMapModel::TYPE_BOOK)
        {
            $count = D('Admin/Novels')->where(['id'=>$_POST['fid'], 'status'=>NovelsModel::STATUS_ON])->count();
            if ($count <= 0)
            {
                $this->error("小说不存在或已下架");
            }
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
//        D($this->model)->createCache();
        D($this->model)->clearBannerCache();
    }

    public function _after_update()
    {
//        D($this->model)->createCache();
        D($this->model)->clearBannerCache();
    }
}