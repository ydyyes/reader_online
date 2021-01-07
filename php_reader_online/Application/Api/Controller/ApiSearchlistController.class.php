<?php

namespace Api\Controller;

class ApiSearchlistController extends IndexController
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
            try {
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
                $top = $data['top'] > 0 ? $data['top'] : 10;
                $list = D('Admin/StatisticKeywords')->group('keyword')->order('sum(count) desc')->limit(0, $top)->getField('keyword', true);
                
                $result['data']['result'] = self::CODE_SUCC;
                $result['data']['list'] = $list;
            } catch (\Exception $e) {
            }
        } while(false);

        return $result;
    }
}