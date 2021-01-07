<?php
/**
 * 生成应用文件的存放目录，及访问链接
 * 'FILE_PATH_DIR' => '/files/Data/Attachments/dev/',          //应用文件存放路径，保留反斜杠 x/x/b/a.pdf
 * 'FILE_PATH_URL' => 'http://domain/dev/',          //应用文件访问URL，保留反斜杠 x/x/b/a.pdf
 *	
 * 获取存储位置统一使用 get_path，获取链接前缀统一使用 get_url，方便扩展二级域名
 *
 * @author shuhai
 */
namespace Helper;

class Url
{
	protected $basePath;
	protected $baseURL;
	protected $pathArray;
	
	function __construct()
	{
		$UrlConfig      = C('UPLOAD_PATH');
		$this->basePath = $UrlConfig['FILE_PATH_DIR'];
		$this->baseURL  = $UrlConfig['FILE_PATH_URL'];
		
		$this->pathArray = array(
				"apk"		=> "apks/",
				"screen"	=> "screens/",
				"icon"		=> "icons/",
				"patch"		=> "patches/",
				"image"		=> "images/",
				"doc"		=> "doc/",
				"user"		=> "user/",
				"test"		=> "test/",
				"ftp"		=> "ftp/",
				"position"	=> "position/",
		);
	}

	function get_path($type = "apk")
	{
		if(empty($type) || empty($this->pathArray[$type]))
			return $this->basePath.$type;
		
		return $this->basePath . $this->pathArray[$type];
	}

	function get_url($type = "apk")
	{
		if(empty($type) || empty($this->pathArray[$type]))
			return $this->baseURL;
		
		return $this->baseURL . $this->pathArray[$type];
	}
}
