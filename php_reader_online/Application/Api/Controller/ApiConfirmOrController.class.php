<?php

namespace Api\Controller;

class ApiConfirmOrController extends IndexController
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
            $orno = $data['orno'];
            $succ = D('Admin/UserPaidLog')->where(['pay_or'=>$orno, 'status'=>1])->COUNT();
            if ($succ)
            {
                $result['data']['result'] = self::CODE_SUCC;
            } else {
                $result['data']['result'] = self::CODE_FAILD;
            }
        } while (false);

        return $result;
    }
}