<?php

namespace Api\Controller;

class ApiCatesController extends IndexController
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
            $result['data']['result'] = self::CODE_SUCC;
            $list = D('Admin/Cates')->getData();
            $info = [];
            foreach ($list as $id => $name)
            {
                $info[] = [
                    'id' => $id,
                    'name' => $name,
                ];
            }
            $result['data']['list'] = $info;
    	} while (false);

        return $result;
    }
}