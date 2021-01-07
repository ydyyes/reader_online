<?php

namespace Admin\Controller\Xs;

use Admin\Controller\SystemController;

/**
 * Class XsChaptersController
 * @package Admin\Controller
 */
class XsChaptersController extends SystemController
{
    const TXT_PATH = 'txt/';
    const BOOK_TMP_PATH = 'book/';
    const PIC_PATH = 'xiaoshuo/';

    public $model = "chapters";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['title']))
        {
            $map['title'] = ['like', '%'.$_search['title'].'%'];
        }
    }




    public function index($model_name=null)
	{
		$this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
		//列表过滤器，生成查询Map对象
		$map = $this->_search ($this->model);
		if (method_exists ( $this, '_filter' )) {
			$this->_filter ( $map );
		}
		$map['nid'] = !isset($map['nid']) ? I('request.nid', 0, 'intval') : $map['nid'];

		$model = D ($this->model);
		if (! empty ( $model )) {
			$this->_list ( $model, $map );
		}

		$this->assign('nid', $map['nid']);
		$this->assign ('map', $map);
		$this->display ();
		return;
	}

    public function add()
    {
        $nid = I('get.nid', 0, 'intval');
        $this->assign('nid', $nid);
        $this->display();
    }

    public function edit()
    {
        $nid = I('get.nid', 0, 'intval');
        $this->assign('nid', $nid);
        $this->display();
    }

    public function insert()
    {
        if (empty($_POST['nid']))
        {
            $this->error("找不到对应小说ID，请联系管理员");
        }
        if (empty($_POST['chapters']))
        {
            $this->error("找不到章节文件，请重新上传");
        }

        $_id = D('Admin/Novels')->where(['id'=>$_POST['nid']])->getField('_id');
        if (empty($_id))
        {
            $this->error('小说的唯一标志 _id 为空');
        }
        $chapters = $this->doWithChapter($_POST['chapters'], $_POST['nid'], $_id);
        if (empty($chapters))
        {
            $this->error("章节为空，请技术人员检查已上传的文件");
        }
        
        try {
            foreach ($chapters as $k => $ch)
            {
                $chapters[$k]['create_at'] = time();
            }
            $res = D("Admin/Chapters")->addAll($chapters);
        } catch (\Exception $e) {
        }

        if ($res!==false)
        {
            D('Admin/Chapters')->createCache($_POST['id']);
            $this->assign ( 'jumpUrl', cookie ( '_currentUrl_' ) );
            $this->success ('新增成功!', 'closeCurrent');
        } else {
            $this->log_error(D($this->model)->getDbError());
            $this->error ('新增失败!');
        }
    }

    public function update()
    {
        if (empty($_POST['nid']))
        {
            $this->error("找不到对应小说ID，请联系管理员");
        }
        if (empty($_POST['chapters']))
        {
            $this->error("找不到章节文件，请重新上传");
        }
        
        $_id = D('Admin/Novels')->where(['id'=>$_POST['nid']])->getField('_id');
        if (empty($_id))
        {
            $this->error('小说的唯一标志 _id 为空');
        }

        $chapters = $this->doWithChapter($_POST['chapters'], $_POST['nid'], $_id);
        if (empty($chapters))
        {
            $this->error("章节为空，请技术人员检查已上传的文件");
        }
        $chapterModel = D("Admin/Chapters");
        $sql = "";
        foreach ($chapters as $k => $ch)
        {
            try {
                $chapterModel->where(['nid'=>$ch['nid'], 'serial'=>$ch['serial']])->save($ch);
            } catch (\Exception $e) {
                $sql .= $chapterModel->getLastSql();
            }
        }
        if ($sql == "")
        {
            D('Admin/Chapters')->createCache($_POST['nid']);
            $this->assign ( 'jumpUrl', cookie ( '_currentUrl_' ) );
            $this->success ('更新成功!', 'closeCurrent');
        } else {
            $this->error ('更新失败! 失败项：' . $sql);
            \Think\Log::write($sql);
        }
    }

    public function doWithChapter($filepath, $novelId, $_id)
    {
        $dir = get_cdn_share_dir('pic');
        if (!file_exists($dir . $filepath))
        {
            $this->error("找不到章节文件，请重新上传");
        }
        $path = self::TXT_PATH . $novelId . "/";
        $mvPath = $dir . "/" . $path;
        if (!is_dir($mvPath))
        {
            mkdir($mvPath, 0777, true);
        }

        $data = [];
        $ext = pathinfo($filepath, PATHINFO_EXTENSION);
        if (in_array($ext, ['rar', 'zip']))
        {
            $rmdir = 1;
            $fileinfo = decompress($dir . $filepath);
            if ($fileinfo['count'] <= 0)
            {
                $this->error("解压缩失败，请重新上传");
            }
            $txts = glob($fileinfo['filepath'] . "/*.txt");
            if (empty($txts))
            {
                $this->error("找不到txt文件，请重新上传");
            }
        } else {
            $txts = [$dir . $filepath];
        }

        foreach ($txts as $val)
        {
            try {
                $book = pathinfo($val);
                $bookname = explode('_', $book['filename']);
                $serial = $bookname[0];
                $fh = fopen($val, 'r');
                $title = trim(fgets($fh));
                fclose($fh);
                $md5 = md5_file($val);
                $name = $serial . "_" . $md5 . ".txt";
                $rename = $mvPath . $name;
                $cmd = sprintf("mv '%s' '%s'", $val, $rename);
                `$cmd`;    

                $data[] = [
                    'nid' => $novelId,
                    '_id' => $_id,
                    'chid' => $md5,
                    'serial' => $serial,
                    'title' => $title,
                    'link' => $path . $name,
                    'update_at' => time(),
                ];
            } catch (\Exception $e) {
                \Think\Log::write($e->getMessage());
            }
        }

        if ($rmdir)
        {
            unlink($dir . $filepath);
            rmdir($fileinfo['filepath']);
        }
        
        return $data;
    }

    public function uploader()
    {
        $type = I('get.type', '');
        if(!IS_POST)
        {
            $this -> display();
            exit;
        }
        $msg = $this->uploadFile($type);
        $this->ajaxReturn($msg,'JSON');
    }

    /**
     * 上传文件的方法
     */
    protected function uploadFile($type)
    {
        $file = $_FILES['file'];
        $flag = 0;
        if ('img' == $type)
        {
            $flag = 1;
            $path = self::PIC_PATH;
            $extArr = ['png','jpg'];
        } elseif ('book' == $type) {
            $path = self::BOOK_TMP_PATH;
            $extArr = ['rar', 'zip', 'txt'];
        }
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
                if (!in_array($ext,$extArr))
                {
                    throw new \Exception("只支持".implode(',', $extArr));
                }
                $filename = $file['name'];
                $dir = get_cdn_share_dir('pic') . $path;
                if ($flag)
                {
                    $uniq = md5(time().uniqid());
                    $nextName = recreate_img_name(substr($uniq, 8, 16).".".$ext);
                    $msg['cover'] = $path.$nextName;
                } else {
                    $nextName = $file['name'];
                    $msg['chapters'] = $path.$nextName;
                }
                $path2 = pathinfo($nextName, PATHINFO_DIRNAME);
                if(!is_dir($dir.$path2))
                {
                    mkdir($dir.$path2, 0777, true);
                }
                $result = move_uploaded_file($file['tmp_name'], $dir . $nextName);
                if (!$result)
                {
                    throw new \Exception("上传失败");
                }
                $msg[$type] = $filename;
                return $msg;
            }
        } catch (\Exception $e) {
            \Think\Log::write(var_export($_POST, true), \Think\Log::WARN);
            \Think\Log::write($e->getMessage(), \Think\Log::WARN);
            $this->error($e->getMessage());
        }
    }

    /**
     * 物理删除
     */
    public function foreverdelete($model_name=null)
    {
        $this->model = $modelName = isset($this->model) ? $this->model : $this->getActionName();
        $model = D ($modelName);
        if (! empty ( $model )) {
            $pk = is_array($model->getPk()) ? current($model->getPk()) : $model->getPk();
            $id = $_REQUEST [$pk];
            if (isset ( $id )) {
                $condition = array ($pk => array ('in', explode ( ',', $id ) ) );
                $nid = D($this->model)->where($condition)->getField('id');
                if (false !== $model->where ( $condition )->delete ()) {
                    D($this->model)->createCache($nid);
                    $this->success ('删除成功！');
                } else {
                    $this->log_error($model->getDbError());
                    $this->error ('删除失败！');
                }
            } else {
                $this->error ( '非法操作' );
            }
        }
        $this->forward ();
    }
}    