<?php

namespace Api\Controller;

/**
 * Class ApiStrategyController
 * 下发客户端的控制策略，暂为全局，不区分渠道
 *
 * @link    /api.php?req=strategy
 * @method  get|post
 */
class ApiStrategyController extends IndexController
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

    /**
     * @return array
     */
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
            //全局配置项
            $config = D('SysConfig')->getAll();
            $prefix = "STRATEGY_";
            foreach ($config as $k => $v)
            {
                if ("\"\"" == $v)
                {
                    $v = "";
                }
                if (false !== strpos($k, $prefix))
                    $data[substr(strtolower($k), 9)] = $v;
            }

            $result['data'] = $data;
        } while (false); 

        return $result;       
    }
}
