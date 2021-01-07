<?php

namespace Api\Controller;

class ApiRecommendController extends IndexController
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

            $where = [];
            $offset = $data['offset'] ? : 0;
            $limit = $data['limit'] ? : 6;
            $order = 'rating desc, create_at desc';
            $channelId = D('Admin/SysChannel')->getChannelIdByName($data['channel']);
            if ($channelId <= 0)
            {
                $result['data']['result'] = self::CODE_SERVER_ERR;
                break;
            }
            $nids = D('Admin/Recommend')->where(['chn_id' => ['like', '%,' . $channelId . ',%']])->order($order)
                ->limit($offset, $limit)->getField('nid', true);

            $novelsModel = D('Admin/Novels');
            $cates = D('Admin/Cates')->getData();
            $over = $novelsModel->over;
            $openlevel = $novelsModel->openlevel;
            $gender = $novelsModel->gender;
            $info = [];
            foreach ($nids as $nid)
            {
                $val = $novelsModel->where(['id'=>$nid])->find();
                $lastChapterInfo = D('Admin/Chapters')->getCache($val['_id'], $val['lastChapter']);
                $isPayChapterInfo = D('Admin/Chapters')->getCache($val['_id'], $val['isPayChapter']);
                $info[] = [
                    '_id' => $val['_id'],
                    'title' => $val['title'],
                    'author' => $val['author'],
                    'longIntro' => $val['longIntro'],
                    'majorCate' => $cates[$val['majorCate']],
                    'minorCate' => '',
                    'cover' => !empty($val['cover']) ? (false !== strrpos($val['cover'], 'http') ? $val['cover'] : cdn('ATTACH') . $val['cover']): "",
                    'rating' => [
                            'count' => (int)$val['count'],
                            'score' => $val['score'],
                            'isEffect' => (bool)$val['isEffect'],
                        ],
                    'hasCopyright' => (bool)$val['hasCopyright'],
                    'buytype' => (int)$val['buytype'],
                    'contentType' => $val['contentType'],
                    'allowMonthly' => (bool)$val['allowMonthly'],
                    'latelyFollower' => (int)$val['latelyFollower'],
                    'wordCount' => (int)$val['wordCount'],
                    'serializeWordCount' => (int)$val['serializeWordCount'],
                    'retentionRatio' => $val['retentionRatio'],
                    'updated' => date("Y-m-d\TH:i:s\Z", $val['updated']), #2018-08-06T16:05:28.372Z
                    'isSerial' => (bool)$val['isSerial'],
                    'chaptersCount' => (int)$val['chaptersCount'],
                    'lastChapter' => $lastChapterInfo[$val['lastChapter']]['title'],
                    'gender' => [(string)$gender[$val['gender']]],
                    'tags' => explode(',', $val['tags']),
                    'cat' => '',
                    'isPayChapter' => $isPayChapterInfo[$val['isPayChapter']]['title'],
                    'openlevel' => (int)$val['openlevel'],
                    'isfree' => (bool)$val['isfree'],
                    'type' => $val['type'],
                    'over' => (int)$val['over'],
                ];
            }
            $result['data']['result'] = self::CODE_SUCC;
            $result['data']['list'] = $info;
    	} while (false);

        return $result;
    }
}