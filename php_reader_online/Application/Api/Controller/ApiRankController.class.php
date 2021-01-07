<?php

namespace Api\Controller;
use Admin\Model\NovelsModel;

class ApiRankController extends IndexController
{
    public function getDecryptData($data)
    {
        return $this->core($data);
    }

    public function getData()
    {
        $header = get_headers_info();
        $data = array_merge($header, $_GET);
        return $this->core($data);
    }

    protected function core($data)
    {
    	$result = ['errno'=>0, 'data'=>[]];
    	do {
    		if (empty($data['uuid']))
            {
                $result['errno'] = self::ERRNO_PARAM_INVALID;
                break;
            }
            //注册
            $user = D('Admin/Users')->register($data['uuid']);
            if (empty($user))
            {
                $result['data']['result'] = self::CODE_SERVER_ERR;
                break;
            }
            $where = $all = $info = [];
            $where['status'] = NovelsModel::STATUS_ON;
            $novelsModel = D('Admin/Novels');  
            $offset = $data['offset'] ? : 0;
            $limit = $data['limit'] ? : 6;
            $nids = [];
            if ($data['hotest'] > 0)
            {
                $nids = D('Admin/StatisticReadtimes')->group('nid')->order('sum(count) desc')->getField('nid', true);
            } elseif ($data['paycount'] > 0) {
                $nids = D('Admin/StatisticChapters')->where(['nid'=>['neq', 0]])->order('fade_persons desc')->getField('nid', true);
            } elseif ($data['shelfcount'] > 0) {
                $nids = D('Admin/StatisticReadtimes')->group('nid')->order('sum(count_shelf) desc')->getField('nid', true);
            }

            if (!empty($nids))
            {
                $where['id'] = ['IN', $nids];
            } else {
                $where['id'] = 0;
            }
            if (!empty($nids))
            {
                $all = $novelsModel->where($where)->order($order)->limit($offset, $limit)->select();
                $tmp = [];
                foreach ($all as $key => $value)
                {
                    $tmpKey = array_search($value['id'], $nids);
                    $tmp[$tmpKey] = $value;
                }
                ksort($tmp);
                $all = $tmp;
                $info = $novelsModel->dataFormat($all);
            }
   
            $result['data']['result'] = self::CODE_SUCC;
            $result['data']['list'] = $info;
    	} while (false);

        return $result;
    }
}