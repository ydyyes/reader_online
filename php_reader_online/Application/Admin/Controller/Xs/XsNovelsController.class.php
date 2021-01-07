<?php

namespace Admin\Controller\Xs;

use Admin\Controller\SystemController;
use Admin\Controller\UploadChapterController;
use Admin\Model\CatesModel;

/**
 * Class XsNovelsController
 * @package Admin\Controller
 */
class XsNovelsController extends SystemController
{
    use UploadChapterController;

    const TXT_PATH = 'admin_txt/';
    const BOOK_TMP_PATH = 'admin_book/';
    const PIC_PATH = 'xiaoshuo/';

    public $model = "novels";

    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['id']))
        {
            $map['id'] = $_search['id'];
        }
        if (isset($_search['title']))
        {
            $map['title'] = ['like', '%'.$_search['title'].'%'];
        }
        if (isset($_search['author']))
        {
            $map['author'] = ['like', '%'.$_search['author'].'%'];
        }
        if (isset($_search['over']))
        {
            $map['over'] = intval($_search['over']);
        }
        if (isset($_search['copyright']))
        {
            $map['copyright'] = ['like', '%'.$_search['copyright'].'%'];
        }
        if (isset($_search['openlevel']))
        {
            $map['openlevel'] = $_search['openlevel'];
        }
        if (isset($_search['maCate']))
        {
            $map['maCate'] = $_search['maCate'];
        }
        if (isset($_search['type']))
        {
            $map['type'] = $_search['type'];
        }
        if (isset($_search['status']))
        {
            $map['status'] = $_search['status'];
        }
    }

    public function chapterDel(){
        $info =D($this->model)->where(['id'=>$_REQUEST['id']])->find();
        if (empty($info))
        {
            $this->error("找不到对应小说，请联系管理员");
        }
        if (empty($info['_id']))
        {
            $this->error('小说的唯一标志 _id 为空');
        }
        if(empty($info['pathChapters'])){
            $this->error('小说没有上传过,请选择正确的修改方式');
        }

        $save['updated']      = '0';
        $save['pathChapters'] = '';
        $save['lastChapter']  = '0';
        $res = D($this->model)->where(['id'=>$_REQUEST['id']])->save($save);
        if($res) {
            D($this->model)->clearDetailCache($_REQUEST['id']);
            $this->assign('jumpUrl', cookie('_currentUrl_'));
            $this->success('上传成功!', 'closeCurrent');
        }else{
            $this->log_error(D($this->model)->getDbError());
            $this->error ('上传失败!');

        }


    }

    public function chapterUpdateSave(){
        $info =D($this->model)->where(['id'=>$_REQUEST['id']])->find();

        if (empty($info))
        {
            $this->error("找不到对应小说，请联系管理员");
        }
        if (empty($info['_id']))
        {
            $this->error('小说的唯一标志 _id 为空');
        }
        if(empty($info['pathChapters'])){
            $this->error('小说没有上传过,请选择正确的修改方式');
        }
        $chapters = $this->decompression($_POST['chapters'], $_REQUEST['id'], $info['_id'],3,$info['pathChapters']);

        if($chapters) {
            D($this->model)->clearDetailCache($_REQUEST['id']);
            $this->assign('jumpUrl', cookie('_currentUrl_'));
            $this->success('上传成功!', 'closeCurrent');
        }else{
            $this->log_error(D($this->model)->getDbError());
            $this->error ('上传失败!');

        }

    }
    public function chapterUpdate(){

        $this->assign('id',$_REQUEST['id']);
        return $this->display();
    }
    /*
     * 章节续传
     */
    public function chapterUploadContinueInsert(){
        $info =D($this->model)->where(['id'=>$_REQUEST['id']])->find();

        if (empty($info))
        {
            $this->error("找不到对应小说，请联系管理员");
        }
        if (empty($info['_id']))
        {
            $this->error('小说的唯一标志 _id 为空');
        }
        if(empty($info['pathChapters'])){
            $this->error('小说没有上传过,请选择正确的修改方式');
        }

        $chapters = $this->decompression($_POST['chapters'], $_REQUEST['id'], $info['_id'],2,$info['pathChapters']);
        if($chapters) {
            D($this->model)->clearDetailCache($_REQUEST['id']);
            $this->assign('jumpUrl', cookie('_currentUrl_'));
            $this->success('上传成功!', 'closeCurrent');
        }else{
            $this->log_error(D($this->model)->getDbError());
            $this->error ('上传失败!');

        }


    }
    public function chapterUploadContinue(){

        $this->assign('id',$_REQUEST['id']);
        return $this->display();
    }
    /**Continue
     * 章节上传
     */
    public function chapterUploadInsert(){
        $info =D($this->model)->where(['id'=>$_REQUEST['id']])->find();

        if (empty($info))
        {
            $this->error("找不到对应小说，请联系管理员");
        }
        if (empty($info['_id']))
        {
            $this->error('小说的唯一标志 _id 为空');
        }
        if(!empty($info['pathChapters'])){
            $this->error('小说已经上传过,请选择正确的修改方式');
        }

        $chapters = $this->decompression($_POST['chapters'], $_REQUEST['id'], $info['_id'],1,'');

        if($chapters) {
            D($this->model)->clearDetailCache($_REQUEST['id']);
            $this->assign('jumpUrl', cookie('_currentUrl_'));
            $this->success('上传成功!', 'closeCurrent');
        }else{
            $this->log_error(D($this->model)->getDbError());
            $this->error ('上传失败!');

        }





    }
    public function chapterUpload(){

        $this->assign('id',$_REQUEST['id']);
        return $this->display();
    }

    public function chapterShow(){

        $info =D($this->model)->where(['id'=>$_REQUEST['id']])->find();
        $data = [];
        if(!empty($info['pathChapters'])){
            $url = fetchIndex($info['pathChapters']);
            $data_json = file_get_contents($url);
            $data= json_decode($data_json,true);
        }
        array_multisort(array_column($data['chapters'],'rename'),SORT_ASC,SORT_NUMERIC,$data['chapters']);
        $data = $data['chapters']?$data['chapters']:[];

        $this->assign('list',$data);
        $this->assign('id',$_REQUEST['id']);
        return $this->display();
    }

    public function _before()
    {    $_REQUEST['orderDirection'] = 'desc';
        $status = D($this->model)->status;
        $over = D($this->model)->over;
        $openlevel = D($this->model)->openlevel;
        $crowd = D($this->model)->crowd;
        $cates = D('Admin/Cates')->getCatesByPid(0);
        if($_GET['id']){
            $info = D($this->model)->where(['id'=>$_GET['id']])->find();
           $chi_cate = D('Admin/Cates')->getCatesByPid($info['majorCate']);
        }
        $comment_real = D($this->model)->comment_real;
        $seriral = D($this->model)->seriral;
        $copyright = D($this->model)->copyright;
        $free = D($this->model)->free;
        $moth = D($this->model)->moth;
        $Newcharts =  D($this->model)->Newcharts;

        $this->assign('chi_cate',$chi_cate);
        $this->assign('Newcharts',$Newcharts);
        $this->assign('moth',$moth);
        $this->assign('free',$free);
        $this->assign('copyright',$copyright);
        $this->assign('seriral',$seriral);
        $this->assign('comment_real',$comment_real);
        $this->assign('status', $status);
        $this->assign('over', $over);
        $this->assign('crowd', $crowd);
        $this->assign('cates', $cates);
        $this->assign('openlevel', $openlevel);
    }

    public function _before_insert()
    {
        if (empty($_POST['cover']))
        {
            $this->error('图片必传');
        }

         if (!isset($_POST['score'])|| !is_numeric($_POST['score']))
         {
             $this->error('评分必须为数字');
         }else{
             $_POST['score'] = sprintf('%.2f',$_POST['score']);
         }
        if (!isset($_POST['retentionRatio'])|| !is_numeric($_POST['retentionRatio']))
        {
            $this->error('留存率必须为数字');
        }else{
            $_POST['retentionRatio'] = sprintf('%.2f',$_POST['retentionRatio']);
        }
        if (empty($_POST['maCate']))
        {
            $this->error('主类型必填');
        }
        if (!is_numeric($_POST['buytype']) || strlen($_POST['buytype']) > 2)
        {
            $this->error('购买类型必须为整数,并且长度最多为十位数');
        }
        if (empty($_POST['cover']))
        {
            $this->error('图片必传');
        }
        $_POST['weight'] = abs($_POST['weight']);
        if (!is_int($_POST['weight']))
        {
            $this->error('权重必须为正整数');
        }
        $res = D($this->model)->where(['cover'=>$_POST['cover']])->find();
        if(!empty($res))
        {
            $status = D($this->model)->status;
            $this->error('该项已经存在,状态：' . $status[$res['status']]);
        }
        $_POST['_id'] = md5($_POST['title'].uniqid());
    }

    public function insertChapter(){
        if (empty($_POST['id']))
        {
            $this->error("找不到对应小说ID，请联系管理员");
        }
        $_id =D($this->model)->where(['id'=>$_POST['id']])->getField('_id');

        if (empty($_id))
        {
            $this->error('小说的唯一标志 _id 为空');
        }
        $chapter_index = D($this->model)->where(['id'=>$_POST['id']])->getfield('pathChapters');


        $chapters = $this->doWithChapter($_POST['chapters'], $_POST['id'], $_id,$chapter_index);


        if($chapters) {
            $this->assign('jumpUrl', cookie('_currentUrl_'));
            $this->success('上传成功!', 'closeCurrent');
        }else{
            $this->log_error(D($this->model)->getDbError());
            $this->error ('上传失败!');

        }

    }


    public function doWithChapter($filepath, $novelId, $_id,$chapter_index)
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
        $data = [];

        if($chapter_index){
            $data = file_get_contents($dir.$chapter_index);
            $data = json_decode($data,true);
            $data = $data?:['chapters'=>[]];
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
                $name = $serial . "_" . $_id . ".txt";
                $rename = $mvPath . $name;


                if($chapter_index){
                        if(!is_file($rename)){
                            $sign =1;
                        }

                        $cmd = sprintf("mv '%s' '%s'", $val, $rename);
                        `$cmd`;

                        if($sign) {
                            array_push($data['chapters'], ['link' => $path.$name, 'title' => $title, "unreadble" => true, 'rename' => $name]);
                        }


                }else{
                    $cmd = sprintf("mv '%s' '%s'", $val, $rename);
                    `$cmd`;

                    $data['chapters'][]= [
                        'link'      => $path,
                        'title'     => $title,
                        "unreadble" => true,
                        'rename' => $name
                    ];

                }


            } catch (\Exception $e) {
                \Think\Log::write($e->getMessage());
            }
                    $sign =0;
        }

        if ($rmdir)
        {
            unlink($dir . $filepath);
            rmdir($fileinfo['filepath']);
        }

        if($data) {

            if (!$chapter_index) {
                $res['pathChapters'] = D($this->model)->createChapterIndex($path);
            } else {
                $res['pathChapters'] = $chapter_index;
            }


            file_put_contents($dir.$res['pathChapters'],json_encode($data));
            $res['updated'] = time();

            $save_res = D($this->model)->where(['id'=>$novelId])->save($res);

            if($save_res){
                return true;
            }else{
                return false;
            }
        }


        return true;
    }


    public function uploadChapter()
    {

        $this->assign('id',$_GET['id']);
        return $this->display ();
    }

    public function _before_update()
    {
        $_POST['weight'] = abs($_POST['weight']);
        if (!is_int($_POST['weight']))
        {
            $this->error('权重必须为正整数');
        }
        if (empty($_POST['maCate']))
        {
            $this->error('主类型必填');
        }
        if (!isset($_POST['score'])|| !is_numeric($_POST['score']))
        {
            $this->error('评分必须为数字');
        }else{
            $_POST['score'] = sprintf('%.2f',$_POST['score']);
        }
        if (!is_numeric($_POST['buytype']) || strlen($_POST['buytype']) > 2)
        {
            $this->error('购买类型必须为整数,并且长度最多为十位数');
        }
        if (!isset($_POST['retentionRatio'])|| !is_numeric($_POST['retentionRatio']))
        {
            $this->error('留存率必须为数字');
        }else{
            $_POST['retentionRatio'] = sprintf('%.2f',$_POST['retentionRatio']);
        }

    }

    public function getAjaxCates(){
        $pid = I('id');
        $cates = D('Admin/Cates')->getCatesByPid($pid);

        if(IS_AJAX) {
            if($cates) {
                exit(json_encode(['errno'=>200,'data'=>$cates]));
            }else{
                exit(json_encode(['errno'=>2001,'data'=>[]]));
            }
        }else{
            return $cates;
        }
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

    public function _after_update()
    {
        $id = $_POST['id'];
        $status = $_POST['status'];
        D('Admin/Chapters')->statusWithNovels($id, $status);
//        D($this->model)->mapping();
        D($this->model)->clearDetailCache($id);
    }

    public function _after_insert()
    {
//        D($this->model)->mapping();
    }
}