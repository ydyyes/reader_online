<?php
namespace Cli\Controller;
use Admin\Model\UserPaidLogModel;

class DayController extends ClibaseController
{
	public function index()
	{
        echo "+---------------------------------------------------------------------+\n";
        echo "+ cli mode useage\n";
        echo "+ 每天各执行一次 php cli.php 控制器/方法 参数1 参数值1 参数2 参数值2\n";
        echo "+---------------------------------------------------------------------+\n";
        echo "php cli.php Day all\n";
        echo "php cli.php Day payment\n";
        echo "php cli.php Day deleteKeywords\n";
        exit;
	}
	public function all()
    {
        try {
            $this->payment();
            $this->deleteKeywords();
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
        }
    }

    public function payment()
    {
        $model = D('Admin/StatisticPayment');
        $logModel = D('Admin/UserPaidLog');
        try {
            $where = [];
            $where['status'] = 1;
            $where['type'] = UserPaidLogModel::TYPE_MEMBER;
            $day = date('Ymd', strtotime('yesterday'));
            $where['create_at'] = [['egt', strtotime($day . "00:00:00")], ['elt', strtotime($day . "23:59:59")]];
            $all = $logModel->where($where)->field(['days', 'channel', 'total_amount'])->select();
            $data = [];
            foreach($all as $val)
            {
                $row = [
                    'channel' => $val['channel'],
                    'persons' => 1,
                    'persons_mon' => $val['days'] == 30 ? 1 : 0,
                    'persons_hy' => $val['days'] == 180 ? 1 : 0,
                    'persons_y' => $val['days'] == 365 ? 1 : 0,
                    'amount' => $val['total_amount'],
                ];
                $data[$val['channel']]['persons'] += $row['persons']; 
                $data[$val['channel']]['persons_mon'] += $row['persons_mon'];
                $data[$val['channel']]['persons_hy'] += $row['persons_hy'];
                $data[$val['channel']]['persons_y'] += $row['persons_y'];
                $data[$val['channel']]['amount'] += $row['amount'];
            }

            if ($data)
            {   
                $insert = [];
                foreach ($data as $channel => $v)
                {
                    $v['channel'] = $channel;
                    $v['day'] = $day;
                    $insert[] = $v;
                }
                $ins = $model->addAll($insert);
                if ($ins)
                {
                    printf("成功存入%d条\n", count($insert));exit;
                } else {
                    if (count($insert))
                    {
                        throw new \Exception("faild");
                    }
                }
            }
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
            printf("%d存入失败\n", $day);
        }
    }

    public function deleteKeywords()
    {
        $model = D('Admin/StatisticKeywords');
        try {
            $limit = 50;
            $day = date('Ymd', strtotime('yesterday'));
            $where['day'] = $day;
            $allKeywords = $model->where($where)->getField('id, keyword', true);
            $top = $model->where($where)->order('count desc')->limit(0, $limit)->getField('id, keyword', true);
            $data = [];
            foreach ($allKeywords as $id => $val)
            {
                try {
                    if (empty($top[$id]))
                    {
                        $d = $model->where(['id'=>$id])->delete();
                    } 
                } catch (\Exception $e) {
                    \Think\Log::write($e->getMessage());
                }        
            }
        } catch (\Exception $e) {
            \Think\Log::write($e->getMessage());
        }
    }
}