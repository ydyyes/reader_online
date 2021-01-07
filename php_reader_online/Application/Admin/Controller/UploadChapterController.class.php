<?php
/**
 * author:liu.
 */

namespace Admin\Controller;


trait UploadChapterController
{
    public $save_count = 10;
    public function decompression($filepath,$novelId,$_id,$type=1,$pathChapters){
       $dir = get_cdn_share_dir('pic');
        if (!file_exists($dir . $filepath))
        {
            $this->error("找不到章节文件，请重新上传");
        }
        $path = self::TXT_PATH . $novelId . "/";

        $mvPath = $dir . "/" . $path;


        $txts = self::uncompress($dir.$filepath);
        if($type == 1 ){
                $arr = self::mv_upload($txts,$mvPath,$dir.$filepath,$_id,$path);
                if($arr){
                    $res=['updated'      => time(),
                          'pathChapters' => $arr['pathChapters'],
                          'lastChapter'  => $arr['lastChapter']
                    ];

                    $save_res = D($this->model)->where(['id'=>$novelId])->save($res);
                    if($save_res){
                        return true;
                    }else{

                        return false;
                    }

                }
        }elseif($type==2){
           $arr =  self::mv_upload_continue($pathChapters,$txts,$dir.$filepath,$_id,$path,$mvPath);

            if($arr){
                $res=['updated'      => time(),
                      'lastChapter'  => $arr['lastChapter']
                ];

                $save_res = D($this->model)->where(['id'=>$novelId])->save($res);
                if($save_res){
                    return true;
                }else{

                    return false;
                }

            }

        }elseif($type==3){
          if(count($txts) > $this->save_count) {
              unlink($dir.$filepath);
              $info = pathinfo($dir.$filepath);
              $rm_dir = $info['dirname'] . "/" . $info['filename'];
              $rm = scandir($rm_dir);
              foreach($rm as $v){
                  if($v!='.' && $v !='..'){
                      unlink($rm_dir.'/'.$v);
                  }
              }
              rmdir($rm_dir);


              $this->error("修改章节书不能超过".$this->save_count);
          }
            self::mv_upload_save($pathChapters,$txts,$dir.$filepath,$_id,$path,$mvPath);
        }

        return true;

    }

    public function mv_upload_save($pathChapters,$txts,$originalPath,$_id,$path,$mvPath){
        if(!preg_match('/admin/',$pathChapters)){
            $this->error("操作失败,只能操作后台上传的书籍");
        }
        $pathChapters_url = fetchIndex($pathChapters);
        $format = self::format_data($pathChapters_url);

           if(empty($format['num'])){
               $this->error("解析失败");
           }

            foreach ($txts as $v){
                $book = pathinfo($v);
                $bookname = explode('_', $book['filename']);
                $serial = $bookname[0];
                if(!is_numeric($serial)){
                    unlink($originalPath);
                    $info = pathinfo($originalPath);
                    $rm_dir = $info['dirname'] . "/" . $info['filename'];
                    $rm = scandir($rm_dir);
                    foreach($rm as $v){
                        if($v!='.' && $v !='..'){
                            unlink($rm_dir.'/'.$v);
                        }
                    }
                    rmdir($rm_dir);

                    $this->error('文件不正确,格式：213_dsadasda2sda432.txt');
                }
                if(!in_array($serial,$format['num'])){
                    unlink($originalPath);
                    $info = pathinfo($originalPath);
                    $rm_dir = $info['dirname'] . "/" . $info['filename'];
                    $rm = scandir($rm_dir);
                    foreach($rm as $v){
                        if($v!='.' && $v !='..'){
                            unlink($rm_dir.'/'.$v);
                        }
                    }
                    rmdir($rm_dir);

                    $this->error('没有'.$serial.'章,请续传后在进行修改');
                }

            }

        foreach ($txts as $val)
        {

                $book = pathinfo($val);
                $bookname = explode('_', $book['filename']);
                $serial = $bookname[0];
                $fh = fopen($val, 'r');
                $title = trim(fgets($fh));
                fclose($fh);
                $new_chapter_name = md5($_id.uniqid(true)).salt(4);
                $name = $serial . "_" . $new_chapter_name . ".txt";
                $rename = $mvPath . $name;

                $cmd = sprintf("mv '%s' '%s'", $val, $rename);
                `$cmd`;

                foreach ($format['key'] as $kk => $vv){

                    if($vv['serial'] == $serial){
                        $unlink[] =  $format['source']['chapters'][$vv['label']];
                        $format['source']['chapters'][$vv['label']] = ['link' => $path.$name, 'title' => $title, "unreadble" => true, 'rename' => $name];
                    }

                }
        }
           $dir = get_cdn_share_dir('pic');
           file_put_contents($dir.$pathChapters,json_encode($format['source']));

           foreach ($unlink as $v){
                unlink($dir.$v['link']);
           }

        unlink($originalPath);
        $info = pathinfo($originalPath);
        $rm_dir = $info['dirname'] . "/" . $info['filename'];
        $rm = scandir($rm_dir);
        foreach($rm as $v){
            if($v!='.' && $v !='..'){
                unlink($rm_dir.'/'.$v);
            }
        }
        rmdir($rm_dir);



        return true;

    }

    public function mv_upload_continue($pathChapters,$txts,$originalPath,$_id,$path,$mvPath){
        if(!preg_match('/admin/',$pathChapters)){
            $this->error("操作失败,只能操作后台上传的书籍");
        }
         $pathChapters_url = fetchIndex($pathChapters);

         $format = self::format_data($pathChapters_url);
        if(empty($format['num'])){
            $this->error("解析失败");
        }


                foreach ($txts as $v){
                    $book = pathinfo($v);
                    $bookname = explode('_', $book['filename']);
                    $serial = $bookname[0];
                    if(!is_numeric($serial)){
                        unlink($originalPath);
                        $info = pathinfo($originalPath);
                        $rm_dir = $info['dirname'] . "/" . $info['filename'];
                        $rm = scandir($rm_dir);
                        foreach($rm as $v){
                            if($v!='.' && $v !='..'){
                               unlink($rm_dir.'/'.$v);
                            }
                        }
                        rmdir($rm_dir);
                        $this->error('文件不正确,格式：213_dsadasda2sda432.txt');
                    }
                    if(in_array($serial,$format['num'])){
                        unlink($originalPath);
                        $info = pathinfo($originalPath);
                        $rm_dir = $info['dirname'] . "/" . $info['filename'];
                        $rm = scandir($rm_dir);
                        foreach($rm as $v){
                            if($v!='.' && $v !='..'){
                                unlink($rm_dir.'/'.$v);
                            }
                        }
                        rmdir($rm_dir);
                        $this->error('有重复章节['.$serial.'章],请修改后在请进行续传');
                    }

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
                $new_chapter_name = md5($_id.uniqid(true)).salt(4);
                $name = $serial . "_" . $new_chapter_name . ".txt";
                $rename = $mvPath . $name;

                $cmd = sprintf("mv '%s' '%s'", $val, $rename);
                `$cmd`;



                array_push($format['source']['chapters'], ['link' => $path.$name, 'title' => $title, "unreadble" => true, 'rename' => $name]);


            } catch (\Exception $e) {
                \Think\Log::write($e->getMessage());
            }

        }

            $dir = get_cdn_share_dir('pic');
            file_put_contents($dir.$pathChapters,json_encode($format['source']));
            $arr = [];
            $res = array_multisort(array_column($format['source']['chapters'],'rename'),SORT_DESC,SORT_NUMERIC,$format['source']['chapters']);
            if($res){
                $ex_num = explode('_',$format['source']['chapters'][0]['rename'])[0];
                $arr['lastChapter'] = $ex_num ? : 0;
            }



         return $arr;

    }

    public function  format_data($pathChapters){

           $index_data = file_get_contents($pathChapters);
           $index_data = json_decode($index_data,true);

           if(!$index_data || !$index_data['chapters']){
               $this->error("索引格式不正确,解析失败");
           }

            $key = [];
            $num = [];
            $data = [];
           foreach ($index_data['chapters'] as $k =>$v){
               $ex_data = explode('_',$v['rename']);
               $serial = $ex_data[0];
               $num[] = $serial;
               $key[$k]['serial']= $serial;
               $key[$k]['label']= $k;
           }
             $data =['key' =>$key,'num'=>$num,'source'=>$index_data];
           return $data;
    }

    public function mv_upload($txts,$mvPath,$originalPath,$_id,$path){
        if (!is_dir($mvPath))
        {
            mkdir($mvPath, 0777, true);
        }
        foreach ($txts as $v){
            $book = pathinfo($v);
            $bookname = explode('_', $book['filename']);
            $serial = $bookname[0];
            if(!is_numeric($serial)){
                unlink($originalPath);
                $info = pathinfo($originalPath);
                $rm_dir = $info['dirname'] . "/" . $info['filename'];
                $rm = scandir($rm_dir);
                foreach($rm as $v){
                    if($v!='.' && $v !='..'){
                        unlink($rm_dir.'/'.$v);
                    }
                }
                rmdir($rm_dir);
                $this->error('文件不正确,格式：213_dsadasda2sda432.txt');
            }

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
                $new_chapter_name = md5($_id.uniqid(true)).salt(4);
                $name = $serial . "_" . $new_chapter_name . ".txt";
                $rename = $mvPath . $name;


                $cmd = sprintf("mv '%s' '%s'", $val, $rename);
                `$cmd`;


                    $data['chapters'][]= [
                        'link'      => $path.$name,
                        'title'     => $title,
                        "unreadble" => true,
                        'rename' => $name];


            } catch (\Exception $e) {
                \Think\Log::write($e->getMessage());
            }

        }
        if($data){
            unlink($originalPath);
            $info = pathinfo($originalPath);
            $rm_dir = $info['dirname'] . "/" . $info['filename'];
            $rm = scandir($rm_dir);
            foreach($rm as $v){
                if($v!='.' && $v !='..'){
                    unlink($rm_dir.'/'.$v);
                }
            }
            rmdir($rm_dir);
            $dir = get_cdn_share_dir('pic');
            $arr = [];
            $arr['pathChapters'] = D($this->model)->createChapterIndex($path);
            file_put_contents($dir.$arr['pathChapters'] ,json_encode($data));
            $res = array_multisort(array_column($data['chapters'],'rename'),SORT_DESC,SORT_NUMERIC,$data['chapters']);
            if($res){
                 $ex_num = explode('_',$data['chapters'][0]['rename'])[0];
                 $arr['lastChapter'] = $ex_num?:0;
            }

            return $arr;
        }

        return false;


    }
    public function uncompress($filepath){
        $ext = pathinfo($filepath, PATHINFO_EXTENSION);
        if (in_array($ext, ['rar', 'zip']))
        {
            $fileinfo = decompress($filepath);


            if ($fileinfo['count'] <= 0)
            {   unlink($filepath);
                $this->error("解压缩失败，请重新上传");
            }
            $txts = glob($fileinfo['filepath'] . "/*.txt");
            if (empty($txts))
            {
                $rm_dir = $fileinfo['filepath'];
                $rm = scandir($rm_dir);
                foreach($rm as $v){
                    if($v!='.' && $v !='..'){
                        unlink($rm_dir.'/'.$v);
                    }
                }
                rmdir($rm_dir);
                unlink($filepath);
                $this->error("找不到txt文件，请重新上传");
            }
        } else {
            $txts = [$filepath];
        }
        return $txts;

    }


}