<?php
namespace Cli\Controller;

class ResetCacheController extends ClibaseController
{
	public function index()
	{
        echo "+---------------------------------------------------------------------+\n";
        echo "+ cli mode useage\n";
        echo "+ php cli.php 控制器/方法 参数1 参数值1 参数2 参数值2\n";
        echo "+---------------------------------------------------------------------+\n";
        echo "php cli.php ResetCache all\n";
        echo "php cli.php ResetCache sysconfig\n";
        echo "php cli.php ResetCache cates\n";
        echo "php cli.php ResetCache upgrade\n";
        echo "php cli.php ResetCache ad\n";
        echo "php cli.php ResetCache chapters\n";
        echo "php cli.php ResetCache mapping\n";
        echo "php cli.php ResetCache carouselmap\n";
        exit;
	}
	public function all()
    {
        try {
            $this->sysconfig();
            $this->cates();
            $this->upgrade();
            $this->ad();
            $this->chapters();
            $this->mapping();
            $this->carouselmap();
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
        }
    }
	
	public function cates()
	{
		D('Admin/Cates')->createCache();
	}

    public function sysconfig()
    {
        D('SysConfig')->makeAll();
    }

    public function upgrade()
    {
        D('Admin/Upgrade')->createCache();
    }

    public function ad()
    {
        D('Admin/Ad')->createCache();
    }

    public function chapters()
    {
        D('Admin/Chapters')->createCache();
    }

    public function mapping()
    {
        D('Admin/Novels')->mapping();
    }

    public function carouselmap()
    {
        D('Admin/CarouselMap')->createCache();
    }
}
