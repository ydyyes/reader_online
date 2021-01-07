<?php

namespace Api\Controller;

class ApiChapterInfoController extends IndexController
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
            $id = D('Admin/Novels')->getId($data['_id']);
            $isfree = D('Admin/Novels')->where(['id'=>$id])->getField('isPayChapter');
            if ($isfree > 0 && $isfree <= $data['serial'])
            {
                $usersModel = D('Admin/Users');
                if (isset($data['token']))
                {
                    $user = $usersModel->getToken($data['token']);
                    if (empty($user) || $user['logDevid'] != $data['uuid'])
                    {
                        $result['data']['result'] = self::CODE_TOKEN_INVALID;
                        break;
                    }
                } else {
                    $user = $usersModel->register($data['uuid']);
                    if (empty($user))
                    {
                        $result['data']['result'] = self::CODE_SERVER_ERR;
                        break;
                    }
                }

                if ($user['expire'] <= time())
                {
                    $result['data']['result'] = self::CODE_EXPIRE_MEM;
                    break;
                }
            }
            
            $result['data']['result'] = self::CODE_SUCC;
            $chapters = D('Admin/Chapters')->getCache($data['_id'], $data['serial']);
            if (false === stripos($chapters[$data['serial']]['link'], 'http://'))
            {
                $content = file_get_contents(ATTACH_PATH . $chapters[$data['serial']]['link']);
            } else {
                $content = file_get_contents($chapters[$data['serial']]['link']);
            }
            
            $result['data']['data'] = $content ? : "";
    	} while (false);

        return $result;
    }
}