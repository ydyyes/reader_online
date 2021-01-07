<?php
namespace Cli\Controller;
use Exception;
use PhpParser\Node\Stmt\TryCatch;
class ManageNovelController extends ClibaseController {
   
  //  private $input_dir="/Users/ydy/Downloads/00/";
    private $input_dir="/wwwroot/data_center/";
    private $MY_CDN='http://static.vipfree.net';
 
    /*
     *  php cli.php  ManageNovel/start
     */
    
    function start() {
        $booksPath=array();
        $this->getFiles($this->input_dir,$booksPath);
        foreach ($booksPath as $path){
            $cl_path=$path . "_cl";
            if(!file_exists($cl_path))//章节索引不在
                continue;
                if(filesize($cl_path)<=0){//删除空文件夹
                    if(!unlink($cl_path))
                        echo "删除章节目录索引空文件失败 \n";
                }
                
                $oldContent=file_get_contents($path);
                if($oldContent){
                    $book = json_decode($oldContent, true);
                    $result=$this->paseZSBook($book,$path);
                    $cpContent=file_get_contents($cl_path);
                    if($cpContent){
                        $chapter =json_decode($cpContent,true);
                        $cpSize=count($chapter['chapters']);
                        $pathInfo=pathinfo($path); 
                        
                        $txtDir= $pathInfo['dirname'] ;
                        $cpRealSize =$this->countTxtFileNum($txtDir);
                        if($cpRealSize==0)
                            continue;
                            echo "title: ".$book['title']." ".$cpRealSize."  ". $cpSize." \n";                     
                            if($cpRealSize!=$cpSize){//真实下载章节是否与目录相符
                                $result['status']=0;
                            }else{
                                $result['chaptersCount']=$cpRealSize;//更新真实下载章节，主要针对 索引是最新章节，目录不是最新章节
                               
                            }
                            
                            $ChapterList=$this->parseChapters($chapter['chapters']);
                            
                            //var_dump($ChapterList);
                            $this->insertBookDetail($result,$ChapterList);
                    }
                    
                    
                }
                
        }
        
    }
    
    private function parseChapters($chapList) {
        $list=array();
        foreach ($chapList as $item){
            $chap=$this->RecordChapters;
            $chap['title']=$item['title'];
         
            $link=$item['link'];
            $link=substr_replace($link,$this->MY_CDN,0,13);
            $chap['link']=$link;
            
            $chap['create_at']=time();
            $chap['update_at']=time();
            
            $rname=$item['rname'];
            $chid=md5($rname);
            $chap['chid']=$chid;
            $index=explode('_', $rname);
            $chap['serial']=(int)$index[0];           
            $list[]=$chap;
        }
        return $list;
    }
    
    private $majoyCate=array(
        '都市人妻'=>1, 
        '职场白领'=>2,
        '乡村风情'=>3,
        '校园学生'=>4,
        '武侠玄幻'=>5,
        '伦理禁忌'=>6,
        '更多情色'=>8       
    );
    
    private $BookDetail=array(
        '_id'=>'', //视频编号
        'title'=>"",//标题
        'author'=>"",//作者
        'majorCate'=>0,   //分类
        'longIntro'=>'', 
        'cover'=>"",   //封面
        'type'=>"",   //参数值 hot、new、reputation、over,对应 新书、热门、口碑、完结；默认new
        'hasCopyright'=>false,    //版权
        'contentType'=>'txt',       //txt文件格式
        'wordCount'=>0,     //字数统计
        'serializeWordCount'=>0,      //更新字数
        'updated'=>0,  //章节更新时间
        'chaptersCount'=>0,       //'章节统计'
        'lastChapter'=>'',     //'最后更新一章节'
        'gender'=>0,//male,female 
        'openlevel'=>1,     //开放尺度 1 2 3 (2)
        'over'=>1,       //是否完结；0 连载 1完结；默认：1/完结
        'copyright'=> '',   //来源
        'create_at'=>0,       
        'update_at'=>0,
        'status'=>1,    //'是否可用状态，图片不存在 或是下载章节残缺都是不可用'
        'tags'=>"", 
    );
    
    
    private $RecordChapters=array(
        'nid'=>0, //对应书的id
        '_id'=>'', //书的索引id
        'title'=>"",//标题
        'link'=>"",//
        'chid'=>"",//md5
        'serial'=>0,   //每次写入章节       
        'create_at'=>0,
        'update_at'=>0,
        );
    
    function insertBookDetail($bookDetail,$chapterList) {
        try {
            $table_book= M('xs_novels');
            $result=$table_book->where("_id='%s'",$bookDetail['_id'])->field("id")->find();
            if(!$result){
                $insertId=$result=$table_book->data($bookDetail)->add();
            }else{
                $insertId = $result['id'];
                //$table_book->where('id='.$insertId)->data($bookDetail)->save();
            }
            $table_chapter= M('xs_chapters');
            foreach ($chapterList as $item){
                $result=$table_chapter->where("chid='%s'",$item['chid'])->field("id")->find();
                if($result)
                    continue;
                    $item['nid']=$insertId;
                    $item['_id']=$bookDetail['_id'];
                    $table_chapter->data($item)->add();
            }
        } catch (Exception $e) {
            echo  $e;
        }
           
        
    }
    
    /*
     * 解析zs的书的细节
     */
    function paseZSBook($book,$jsonPath) {
        $mybookDetail=$this->BookDetail;
        $mybookDetail['_id']=md5($book['_id']);
        $mybookDetail['title']=$book['title'];
        $mybookDetail['author']=$book['author'];
        $mybookDetail['longIntro']=$book['longIntro'];
        
        $cate=$book['majorCate'];
      
        foreach ($this->majoyCate as $key => $value ){ 
            if(strstr($key,$cate)){
                var_dump($cate);
                $mybookDetail['majorCate']=$value;
            }
        } 
        
        $mybookDetail['majorCate']=9;
        //die();
        
        $mybookDetail['type']=$book['type'];
        $mybookDetail['hasCopyright']=$book['hasCopyright'];
        $mybookDetail['contentType']=$book['contentType'];
        $mybookDetail['wordCount']=$book['wordCount'];
        $mybookDetail['serializeWordCount']=$book['serializeWordCount'];
        
        $mybookDetail['chaptersCount']=$book['chaptersCount'];
        $mybookDetail['lastChapter']=$book['lastChapter'];
        
         $mybookDetail['tags']=implode(',',$book['tags']);
         
        //$mybookDetail['gender']=$book['gender'];
        $mybookDetail['openlevel']=$book['openlevel'];
        $mybookDetail['copyright']=$book['copyright'];
        $mybookDetail['create_at']=time();
        $mybookDetail['update_at']=time();
        
        $mybookDetail['openlevel']=$book['openlevel'];
   
        
        
        $cpTime=strtotime($book['updated']);
        //var_dump($cpTime);
        $mybookDetail['updated']=$cpTime;
        
        if((time()-$cpTime)<=$this->UPTIME_INTERVAL){//更新章节小于一个月表示连载
            $mybookDetail['over']=0;
        }else{
            $mybookDetail['over']=1;
        }
        $cover=$book['cover'];
        $cover=substr_replace($cover,$this->MY_CDN,0,13);
   
        $mybookDetail['cover']=$cover;
         
        if($mybookDetail['longIntro']){
          //  var_dump($mybookDetail);
        }else{
            $mybookDetail['longIntro']="";
        }
        
        if(!$mybookDetail['tags'])
            $mybookDetail['tags']="";
        return $mybookDetail;
        
    } 
    

      
      function syncBooks() {
          $this->dir_copy($this->ZSIndex["jpg"],$this->ZSOutBook["jpg"]);
        
          $txtDir=$this->getDirs($this->ZSIndex['json']);
          foreach ($txtDir as $dir) {
            $pathInfo=pathinfo($dir);
            $dirName=$pathInfo['basename'];
            //生存hash文件目录
            $hs_value=hash('crc32', $dirName);
            $txt_tmp_dir=$this->ZSOutBook["dir"].$hs_value;
            var_dump($txt_tmp_dir);
            if(!file_exists($txt_tmp_dir)){
                mkdir($txt_tmp_dir, 0755, true);
            }
            
         }        
          
          $booksPath=array();
          $this->getFiles($this->ZSIndex['json'],$booksPath);
          foreach ($booksPath as $path){
              $oldContent=file_get_contents($path);
              if($oldContent){
                  $book = json_decode($oldContent, true);
                  $cate=$book['majorCate'];
                  $bookPath=pathinfo($path);
                  $names=explode("_", $bookPath['filename']);
                  var_dump($names[0]);
                  $bookName=$names[0];
                  $cat_value=hash('crc32', $cate);
                  $book_value=hash('crc32', $bookName);
                  
                  $inBookDir=$this->ZSIndex['txt'].$bookName;
                  $outBookidr=$this->ZSOutBook['dir']."/".$cat_value."/".$book_value;
                  $this->fix_zs_dir($inBookDir,$outBookidr);
                  //cp json
                  copy($path, $outBookidr."/".$bookPath['basename']);
                  copy($path."_cl", $outBookidr."/".$bookPath['basename']."_cl");
                  var_dump($outBookidr."/".$bookPath['basename']."_cl");
                  die();
              }
              
              
           
           
            //  $oldContent=file_get_contents($path);
              
          }
          
      }
      
      function fix_zs_dir($src,$dst) {
          var_dump($src);
          if(!file_exists($src))
              return;
          
            if(!file_exists($dst))
                  mkdir($dst,0755, true);
          $handle = opendir($src);   
          $chaptersName=array();
          while ( false !== ( $file = readdir( $handle ) ) ) {
              if ( $file == '.' | $file == '..' )
                  continue;;
                  if(is_file($src."/".$file)){
                      $key=explode("_", $file)['0'];
                      $chaptersName[$key]=$file;                      
                  }
          }
          closedir($handle);  
          ksort($chaptersName);
          foreach ($chaptersName as $key => $value){
              $srcFile= $src .'/'.$value;
              $index=$key+1;
              $rand = md5(time() . mt_rand(0,10000));//生成章节随机key，防止预测
              $fileName=$index."_".$rand.".txt";
              
              if(!file_exists($dst.'/'.$fileName))
              copy($srcFile, $dst.'/'.$fileName);
            // var_dump($fileName);
              //var_dump($dst.'/'.$fileName);
              
          }
         // var_dump($chaptersName);
          
      }
      
      
      
      
      
      function dir_copy($src,$dst){        
          if(!file_exists($dst))
              mkdir($dst,0755, true);
          
          $dir = opendir($src);
          while(false !== ( $file = readdir($dir)) ) {
              if ( $file == '.' | $file == '..' )
                  continue;                                
               if (is_dir($src . '/' . $file) ) {
                   
                      $this->dir_copy($src . '/' . $file,$dst . '/' . $file);
                  }
                  else {                    
                      $result = copy($src . '/' . $file,$dst . '/' . $file);
                      if(!$result){
                         echo "cp fail".$src ."\n"; 
                      }
                  }
             
          }
          closedir($dir);
          
      }
      
    
    
    

    
 
    
    function countTxtFileNum($dir) {
        if(!file_exists($dir))
            return 0;
        if ( !is_dir( $dir ) ) return 0;;
        $handle = opendir( $dir );
        $n=0;
        while ( false !== ( $file = readdir( $handle ) ) ) {
        $filePath="$dir/$file";
            //var_dump($file);
            //var_dump(filesize($filePath));
           
        if(is_file($filePath)&filesize($filePath)>0){
                $ext =pathinfo($file)['extension'];             
                if(strcmp($ext, 'txt')==0){
                    ++$n; 
                }
            }
        }
        closedir($handle);
        
        return $n;
    }
    
  
    /**
     * 遍历获取目录下的指定类型的文件
     * @param $path
     * @param array $files
     * @return array
     */
    function getfiles( $path , &$files = array() )
    {
        if ( !is_dir( $path ) ) return null;
        $handle = opendir( $path );
        while ( false !== ( $file = readdir( $handle ) ) ) {
            if ( $file != '.' && $file != '..' ) {
                $path2 = $path . '/' . $file;
                // print($path2);
                if ( is_dir( $path2 ) ) {
                    $this->getfiles( $path2 , $files );
                } else {
                    if ( preg_match( "/\.(json)$/i" , $file ) ) {
                        $files[] = $path2;
                    }
                }
            }
        }
        closedir($handle);
        return $files;
    }
    
   /*
    * php cli.php  ManageNovel/update_book
    */
   function update_book() {
       $table_book= M('xs_novels');
       $result=$table_book->getField('id,serializeWordCount,wordCount,chaptersCount,isPayChapter,score,latelyFollower,retentionRatio');
       if($result){
           foreach ($result as $item){
               $end=array();
               $count=$item['chaptersCount'];
              // var_dump($result);
               //die();
               if($count<=0)
                 continue;
                 $end['wordCount']=$item['wordCount']>0?$item['wordCount']:$count*700;
                 $end['serializeWordCount']=$item['serializeWordCount']>0?$item['serializeWordCount']:rand(500,5000);
                 if($item['isPayChapter']>0){
                     $end['latelyFollower']=$item['latelyFollower']>0?$item['latelyFollower']:rand(10000,100000);
                 }else{
                     $end['latelyFollower']=$item['latelyFollower']>0?$item['latelyFollower']:rand(100,10000);
                 }
              
                 $end['isPayChapter']=$item['isPayChapter']>0?$item['isPayChapter']:30;
                 $end['score']=$item['score']>0?$item['score']:8; 
                 $end['retentionRatio']=$item['retentionRatio']>0?$item['retentionRatio']:rand(30.5,75.5);
                try {
                    $result=$table_book->where('id=%d',$item['id'])->save($end);
                    var_dump($result);       
                } catch (Exception $e) {
                    echo $e;
                }
                
                       
                 
           }
       }
       
   } 
    
  
    
}