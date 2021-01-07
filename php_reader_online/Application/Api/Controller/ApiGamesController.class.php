<?php

namespace Api\Controller;
use Admin\Model\GamesModel;

class ApiGamesController extends IndexController
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
            
            $offset = $data['offset'] ? : 0;
            $limit = $data['limit'] ? : 6;
            $games = D('Admin/Games')->where(['status'=>GamesModel::STATUS_ON])->order('create_at desc')->limit($offset, $limit)->select();
            foreach ($games as $val)
            {
                
                unset($val['create_at'], $val['update_at'], $val['status']);
                $val['img'] = cdn(ATTACH) . $val['img'];
                $info[] = $val;
            }
            $result['data'] = $info;
    	} while (false);

        return $result;
    }
}