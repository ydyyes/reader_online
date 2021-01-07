<?php
namespace Cli\Controller;
use Admin\Model\UsersModel;

class LogController extends ClibaseController
{
	public function index()
	{
        echo "+---------------------------------------------------------------------+\n";
        echo "+ cli mode useage\n";
        echo "+ php cli.php 控制器/方法 参数1 参数值1 参数2 参数值2\n";
        echo "+---------------------------------------------------------------------+\n";
        echo "php cli.php Log all\n";
        echo "php cli.php Log readtimesSave\n";
        echo "php cli.php Log dloadtimesSave\n";
        echo "php cli.php Log keywordsSave\n";
        echo "php cli.php Log chaptersSave\n";
        echo "php cli.php Log gameLockCheck\n";
        exit;
	}
	public function all()
    {
        try {
            $this->readtimesSave();
            $this->dloadtimesSave();
            $this->keywordsSave();
            $this->chaptersSave();
            $this->gameLockCheck();
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
        }
    }

    public function readtimesSave()
    {
        $redis = \Think\Cache::getInstance();
        $model = D('Admin/StatisticReadtimes');
        $key = $model->getCacheKey();
        $llen = $redis->llen($key);
        $novelModel = D('Admin/Novels');
        for($i = 0; $i < $llen; $i++)
        {
            $r = $redis->lpop($key);
            try {
                $row = json_decode($r, true);
                if (empty($row))
                {
                    throw new \Exception("json_decode faild:" . $r . "\n");
                }
                
                $nid = $novelModel->getId($row['_id']);
                if (empty($nid))
                {
                    throw new \Exception('id not found searching with _id:' . $r . "\n");
                }
                $name = $row['true'];
                unset($row['_id'], $row['true']);
                $row['nid'] = $nid;
                $date = date('Ymd');
                $count = $model->where(['day'=>$date, 'nid'=>$nid])->find();
                if ($count)
                {
                    $model->where(['id'=>$count['id']])->save([$name=>$count[$name] + 1 ]);
                } else {
                    $row['day'] = $date;
                    $row[$name] += 1;
                    $model->add($row);
                }
            } catch(\Exception $e) {
                \Think\Log::write($e->getMessage());
            }
        }
    }

    public function dloadtimesSave()
    {
        
    }

    public function keywordsSave()
    {
        $redis = \Think\Cache::getInstance();
        $model = D('Admin/StatisticKeywords');
        $key = $model->getCacheKey();
        $llen = $redis->llen($key);
        for($i = 0; $i < $llen; $i++)
        {
            $r = $redis->lpop($key);
            try {
                $row = json_decode($r, true);
                if (empty($row))
                {
                    throw new \Exception("json_decode faild:" . $r . "\n");
                }
                $date = date('Ymd');
                $count = $model->where(['day'=> $date, 'keyword'=>$row['keyword']])->find();
                if ($count)
                {
                    $model->where(['id'=>$count['id']])->save(['count'=>$count['count'] + 1 ]);
                } else {
                    $row['day'] = $date;
                    $row['count'] = 1;
                    $model->add($row);
                }
            } catch(\Exception $e) {
                \Think\Log::write($e->getMessage());
            }
        }
    }

    public function chaptersSave()
    {
        $redis = \Think\Cache::getInstance();
        $model = D('Admin/UserPaidLog');
        $key = $model->getCacheKey();
        $llen = $redis->llen($key);
        $chapterModel = D('Admin/StatisticChapters');
        for($i = 0; $i < $llen; $i++)
        {
            $row = $redis->lpop($key);
            try {
                if (empty($row))
                {
                    continue;
                }
                $row = $model->getStatisticLog($row);
                $data = [
                    'nid' => empty($row['_id']) ? 0 : D('Admin/Novels')->getId($row['_id']),
                    'serial' => $row['serial'],
                    'center' => empty($row['center']) ? 0 : 1,
                    'persons' => 1,
                    'persons_mon' => $row['days'] == 30 ? 1 : 0,
                    'persons_hy' => $row['days'] == 180 ? 1 : 0,
                    'persons_y' => $row['days'] == 365 ? 1 : 0,
                ];
                $find = $chapterModel->where([
                    'center'=>$data['center'], 'nid'=>$data['nid'], 'serial'=>$data['serial']
                    ])->find();
                if (empty($find))
                {
                    $chapterModel->add($data);
                } else {
                    $find['persons'] += 1;
                    $find['persons_mon'] += $data['persons_mon'];
                    $find['persons_hy'] += $data['persons_hy'];
                    $find['persons_y'] += $data['persons_y'];
                    $chapterModel->where(['id'=>$find['id']])->save($find);
                }
            } catch(\Exception $e) {
                \Think\Log::write($e->getMessage());
            }
        }
    }

    public function gameLockCheck()
    {
        $redis = \Think\Cache::getInstance();
        $key = D('Admin/Users')->getGameLockTimeoutKey();
        $it = NULL;
        $expire = [];
        do {
            $value = $redis->hscan($key, $it, '', 1000);

            if ($value !== FALSE) {
                foreach($value as $k => $v) {
                    if (time() - $v >= UsersModel::GAME_LOCK_TIMEOUT)
                    {
                        $expire[$k] = $k;
                    }
                }
            }
        } while ($it > 0);

        if (!empty($expire))
        {
            $expire = array_chunk($expire, 2);
            $userModel = D('Admin/Users');
            foreach ($expire as $val)
            {
                try {
                    $s = $userModel->where(['id'=>['IN', $val]])->save(['lock'=>UsersModel::LOCK_GAMECOIN_OFF]);
                    if ($s > 0)
                    {
                        foreach ($val as $a)
                        {
                            $redis->hdel($key, $a);
                        }
                    }
                } catch (\Exception $e) {
                    \Think\Log::write($e->getMessage());
                } 
            }
        }
    }
}