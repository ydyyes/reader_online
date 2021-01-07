<?php

namespace Api\Controller;


/**
 * Class ApiUpgradeController
 * @package Api\Controller
 */
class ApiUpgradeController extends IndexController
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
        $result = ['errno' => 0, 'data' => ['update' => false]];
        do {
            try {
                $channel = $data['channel'];
                $vcode = $data['vcode'];
                $info = D('Admin/Upgrade')->getValue($channel);
                $maxVcode = (int)max(array_column($info, 'version'));
                if ($maxVcode > $vcode)
                {
                    foreach ($info as $val)
                    {
                        if ($val['version'] == $maxVcode)
                        {
                            $resultData = [
                                'md5' => $val['md5'],
                                'version' => $val['version'],
                                'apk_url' => cdn(ATTACH) . $val['apk_url'],
                                'target_size' => (int)$val['target_size'],
                                'update_log' => $val['update_log']
                                ];
                            break;
                        }
                    }

                    $result['data'] = array_merge(['update'=>true], $resultData);
                }
            } catch (\Exception $e) {
            }
        } while(false);

        return $result;
    }
}