<?php

namespace Api\Controller;

class ApiAdListController extends IndexController
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
            //strategy
            $tmp = [];
            $config = D('SysConfig')->getAll();
            $prefix = "STRATEGY_";
            foreach ($config as $k => $v)
            {
                if ("\"\"" == $v)
                {
                    $v = "";
                }
                if (false !== strpos($k, $prefix) && in_array($k, ['STRATEGY_AD_SHOW_TIMES_EVERYDAY', 'STRATEGY_AD_SHOW_INTV', 'STRATEGY_AD_OPEN']))
                {
                    $tmp[substr(strtolower($k), 9)] = (int)$v;
                }
            }

            if ($tmp['ad_open'] > 0)
            {
                $data = D('Admin/Ad')->getData($data['channel'], $data['vcode']);
                $result['data']['result'] = self::CODE_SUCC;
                $result['data']['data'] = empty($data) ? "" : $data;
                $result['data']['strategy'] = $tmp;
            } else {
                $result['data'] = [];
            }
        } while (false);        

        return (array)$result;
    }
}