<?php

namespace Admin\Controller;

use Admin\Controller\SystemController;


/**
 * Class UpgradeController
 * @package Admin\Controller
 */
class UpgradeController extends SystemController
{
    const APK_PATH = "apk/";
    public $model = "upgrade";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['md5']))
        {
            $map['md5'] = ['like', '%'.$_search['md5'].'%'];
        }
    }

    public function _before()
    {
        $channels = D('Admin/SysChannel')->where(['status' => 1])->getField('id,name', true);
        $this->assign('status', D($this->model)->status);
        $this->assign('channels', $channels);
    }

    public function _before_insert()
    {
        if (empty($_POST['chn_id']))
        {
            $_POST['chn_id'] = "";
        } else {
            $_POST['chn_id'] = "," . trim(implode(',', $_POST['chn_id'])) . ",";
        }
        $_POST = array_map('trim', $_POST);
        if (empty($_POST['md5']))
        {
            $this->error("请上传文件");
        }
        $exist = D($this->model)->where(['md5'=>$_POST['md5']])->count();
        if ($exist)
        {
            $this->error('apk文件重复，请重新上传');
        }
    }

    public function _before_update()
    {
        if (empty($_POST['chn_id']))
        {
            $_POST['chn_id'] = "";
        } else {
            $_POST['chn_id'] = "," . trim(implode(',', $_POST['chn_id'])) . ",";
        }
        $_POST = array_map('trim', $_POST);
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
                $extArr = ['apk','zip'];
                if (!in_array($ext,$extArr))
                {
                    throw new \Exception("只支持apk,zip");
                }
                $filename = $file['name'];
                $dir = get_cdn_share_dir('pic') . self::APK_PATH;
                if(!is_dir($dir))
                {
                    mkdir($dir, 0777, true);
                }
                $apkInfo = `aapt dump badging "{$file['tmp_name']}" | head -n 1`;
                preg_match("/versionCode=.*?(\d{1,}).*?/", $apkInfo, $match);
                if (empty($match[1]) || $match[1] <= 0)
                {
                    throw new \Exception("versionCode 获取失败，请重新上传");
                }
                $msg['version'] = $match[1];
                $msg['md5'] = md5_file($file['tmp_name']);
                $msg['target_size'] = filesize($file['tmp_name']);
                $result = move_uploaded_file($file['tmp_name'], $dir . $filename);
                if (!$result)
                {
                    throw new \Exception("上传失败");
                }
                $msg['name'] = $filename;
                $msg['apk_url'] = self::APK_PATH.$filename;
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
        D($this->model)->createCache();
    }

    public function _after_update()
    {
        D($this->model)->createCache();
    }
}