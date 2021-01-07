<?php

namespace Api\Controller;

class ApiCountController extends IndexController
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
            }
            if (D('Admin/StatisticReadtimes')->setShelfUniq($uniq, $data['_id']))
            {
                D('Admin/StatisticReadtimes')->addToQueue(['_id'=>$data['_id'], 'true'=>'count_shelf']);
            }
            $result['data']['result'] = self::CODE_SUCC;
    	} while (false);

        return $result;
    }
}