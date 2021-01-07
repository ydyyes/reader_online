<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Apin\Controller\V1\BaseController;
use Common\Controller\Datasource;

class SetUserInfoController extends BaseController
{
    protected $login = 1;
    const PIC_PATH = "head_portrait/";

    public function save(){


        if(in_array($this->parm['sex'],[-1,1,2]) ){

            $data['sex'] = $this->parm['sex'];
        }

        if(!empty($this->parm['nickname'])){

            if(  mb_strlen($this->parm['nickname'], 'utf8') >= 20){
                $this->returnResult(300115);
            }

            $data['nickname'] = $this->parm['nickname'];
        }

        if(!empty($_FILES['portrait'])){
             $pic = self::uploadFile();
             if(!$pic){
                 $this->returnResult(2001);
             }

             $data['cover'] = $pic['img'];
        }

        $user_model = D('Admin/Users');
        $res = $user_model->where(['id' => $this->userinfo['id']])->save($data);

        if($res){
            $redis = Datasource::getRedis('instance1');
            $list = $redis->hgetall($this->userinfo['uni_id']);

            foreach ($list as $k => $v) {
                if ($redis->hget($k, 'uni_id')) {
                    foreach ($data as  $kk => $vv) {
                        $redis->hset($k, $kk, $data[$kk]);
                    }
                }
            }
        }

        $this->returnResult(200);

    }

    /**
     * 上传文件的方法
     */
    protected function uploadFile()
    {
        $file = $_FILES['portrait'];
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
            return false;
        }
    }

}