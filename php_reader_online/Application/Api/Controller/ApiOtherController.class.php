<?php

namespace Api\Controller;
use Admin\Model\NovelsModel;

class ApiOtherController extends IndexController
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
            $id = D('Admin/Novels')->getId((string)$data['_id']);
            if ($id)
            {
                $list = D('Admin/Novels')->where(['id'=>$id])->select();
                $list = D('Admin/Novels')->dataFormat($list);
            }

            $result['data']['result'] = self::CODE_SUCC;
            $result['data']['data'] = $list ? $list[0] : [];
    	} while (false);

        return $result;
    }
}