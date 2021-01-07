<?php
/**
 * User:Xxx
 */

namespace Common\Reflect;


use Common\Controller\Datasource;

class GoldController extends BaseController
{
    public function goldTime($data ,$user_info){
        $redis = Datasource::getRedis('instance1');
       if($redis->set(self::lockGold($user_info['id']), 1, ['nx', 'ex' => 180])) {

           if ($user_info['gold'] - $data['cost_gold'] < 0) {

               return 300113;
           }

           $data['describe'] = sprintf($data['name'] . '消费' . $data['cost_gold'] . '金币');

           $res = self::goldDispose($data, $user_info);
           $redis->del(self::lockGold($user_info['id']));
           if ($res) {
               return 'success';
           } else {
               return 'fail';
           }
       }else{
           return 2001;
       }
    }
    public function goldBook($data,$user_info){
        $redis = Datasource::getRedis('instance1');
        if($redis->set(self::lockGold($user_info['id']), 1, ['nx', 'ex' => 180])) {
            if ($user_info['gold'] < $data['cost_gold']) {
                return 300113;
            }
            $novel_model = D('Admin/Novels');
            $detail = $novel_model->getDetailById($data['b_id']);
            if (!$detail) {
                return 400104;
            }
            $data['name'] = '兑换缓存小说';
            $data['describe'] = sprintf('缓存小说<<' . $detail['title'] . '>>');

            $res = self::goldDisposeBook($data, $user_info);
            $redis->del(self::lockGold($user_info['id']));
            if ($res) {
                return 'success';
            } else {
                return 'fail';
            }
        }else{
            return 2001;
        }


    }

    private function lockGold($uid){
        return C('REDIS_PREFIX').'lock_gold_'.$uid;
    }


}