<?php
namespace Cli\Controller;

class TmpController extends ClibaseController
{
	public function index()
	{
        echo "+---------------------------------------------------------------------+\n";
        echo "+ cli mode useage\n";
        echo "+ 临时执行 php cli.php 控制器/方法 参数1 参数值1 参数2 参数值2\n";
        echo "+---------------------------------------------------------------------+\n";
        echo "php cli.php Tmp RecommendChannel\n";
        exit;
	}
	public function RecommendChannel()
    {
        try {
            $recommend = D('Admin/Recommend');
            $data = $recommend->select();
            $channels = D('Admin/SysChannel')->getField('id', true);
            $channels = "," . trim(implode(',', $channels)) . ",";
            foreach ($data as $val)
            {
                $recommend->where(['id'=>$val['id']])->save(['chn_id'=>$channels]);
            }
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
        }
    }

    public function initGuser()
    {
        try {
            $users = D('Admin/Users');
            $data = $users->select();
            foreach ($data as $val)
            {
                $guser = $users->createGuser($val['devid'], $val['create_at']);
                $users->where(['id'=>$val['id']])->save(['guser'=>$guser]);
            }
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
        }
    }
}