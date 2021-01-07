<?php

namespace Api\Controller;
use Admin\Model\NovelsModel;
use Admin\Model\RecommendModel;

class ApiNovelsController extends IndexController
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
            $info = D('Admin/Users')->register($data['uuid']);
            if (empty($info))
            {
                $result['data']['result'] = self::CODE_SERVER_ERR;
                break;
            }
            $where = $all = $nids = [];
            $where['status'] = NovelsModel::STATUS_ON;
            $novelsModel = D('Admin/Novels');  
            if ($data['rand'] > 0)
            {
                $rand = [];
                $recommendModel = D('Admin/Recommend');
                $recWhere = ['status' => RecommendModel::STATUS_ON];
                $count = $recommendModel->where($recWhere)->count();
                if ($count <= $data['rand'])
                {
                    $nids = $recommendModel->where($recWhere)->getField('nid', true);
                } else {
                    $i = 0;
                    while ($i < $data['rand']) {
                        $id = rand(1, $count);
                        $find = $recommendModel->where(['id'=>$id])->find();
                        if ($find['status'] > 0 && !in_array($id, $rand))
                        {
                            $nids[] = $find['nid'];
                            $i++;
                            $rand[] = $id;
                        }
                    }
                }  
                if (!empty($nids))
                {
                    $all = $novelsModel->where(['id' => ['IN', $nids]])->select();
                }
            } else {
                $offset = $data['offset'] ? : 0;
                $limit = $data['limit'] ? : 6;
                $order = 'id asc';
                if ($data['majorCate'] > 0)
                {
                    $where['majorCate'] = (int)$data['majorCate'];
                    $order = 'weight desc';
                }
                if ($data['title'])
                {
                    $where['title'] = ['like', '%' . (string)$data['title'] . '%'];
                    D('Admin/StatisticKeywords')->addToQueue(['keyword'=>$data['title']]);
                }
                if ($data['openlevel'] > 0)
                {
                    $where['openlevel'] = $data['openlevel'];
                }
                if ($data['newest'] > 0)
                {
                    $order = 'create_at desc';
                }
                
                if ($data['hotest'] > 0)
                {
                    $nids = D('Admin/StatisticReadtimes')->group('nid')->order('sum(count) desc')->getField('nid', true);
                    if (!empty($nids))
                    {
                        $where['id'] = ['IN', $nids];
                    }
                } 
                
                $all = $novelsModel->where($where)->order($order)->limit($offset, $limit)->select();
                
            }
            if (!empty($nids))
            {
                $tmp = [];
                foreach ($all as $key => $value)
                {
                    $tmpKey = array_search($value['id'], $nids);
                    $tmp[$tmpKey] = $value;
                }
                ksort($tmp);
                $all = $tmp;
            }
            $info = $novelsModel->dataFormat($all);
            
            $result['data']['result'] = self::CODE_SUCC;
            $result['data']['list'] = $info;
    	} while (false);

        return $result;
    }
}