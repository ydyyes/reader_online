<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


class UpgradeController extends BaseController
{
    public function read(){
        //用户检测

        $data = ['update' => false];
        $channel = $this->header['channel'];
        $vcode = $this->header['vcode'];
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
                        'forced_updating' => $val['forced_updating'],
                        'target_size' => (int)$val['target_size'],
                        'update_log' => $val['update_log']
                    ];
                    break;
                }
            }

            $data = array_merge(['update'=>true], $resultData);
        }

        $this->returnResult(200,'',$data);

    }

}