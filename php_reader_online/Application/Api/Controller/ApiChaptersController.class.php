<?php

namespace Api\Controller;

class ApiChaptersController extends IndexController
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
            $uniq = $data['uuid'];
            if (isset($data['token']))
            {
                $uniq = $data['token'];
                $user = D('Admin/Users')->getToken($uniq);
            } else {
                $user = D('Admin/Users')->where(['username'=>$uniq])->find();
            }
            if (D('Admin/StatisticReadtimes')->setUniq($uniq, $data['_id']))
            {
                D('Admin/StatisticReadtimes')->addToQueue(['_id'=>$data['_id'], 'true'=>'count']);
            }
            $_id = $data['_id'];
            $id = D('Admin/Novels')->getId($_id);
            $isPayChapter = D('Admin/Novels')->where(['id'=>$id])->getField('isPayChapter');
            $free = true;
            if ($isPayChapter > 0)
            {
                if ($user['expire'] <= time())
                {
                    $free = false;
                }
            }
            $chapters = D('Admin/Chapters')->getCache($_id);
            $result['data']['result'] = self::CODE_SUCC;
            $info = [];
            foreach ($chapters as $k => $c)
            {
                $c['isfree'] = true;
                if ($isPayChapter > 0)
                {
                    if ($c['serial'] < $isPayChapter)
                    {
                        $c['isfree'] = true;
                    } else {
                        if (false === $free) {
                            $c['isfree'] = false;
                        }    
                    }
                }
                unset($c['id'], $c['nid'], $c['chid'], $c['link']);
                $c['serial'] = (int)$c['serial'];
                $c['link'] = "http://" . $_SERVER['HTTP_HOST']. "/api.php?req=chapterInfo&_id={$c['_id']}&serial={$c['serial']}";
                $info[] = $c;
            }
            array_multisort(array_column($info, 'serial'), SORT_ASC, SORT_NUMERIC, $info);
            $result['data']['list'] = $info;
    	} while (false);

        return $result;
    }
}