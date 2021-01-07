<?php
namespace Admin\Model;
use Common\Controller\Datasource;

/**
 * Class UsersModel
 * @package Admin\Model
 */
class UsersModel extends SystemModel
{
	protected $trueTableName = 'xs_users';
	
	public $_auto		=	array(
	    array('create_at','time',self::MODEL_INSERT,'function'),
        array('create_time','time',self::MODEL_INSERT,'function'),
        array('update_time','time',self::MODEL_UPDATE,'function'),
	);

	const STATUS_ON = 1;
	const STATUS_OFF = 0;

	const USER_TYPE_VISITOR  = 1;
    const USER_TYPE_GENERAL  = 2;
    const USER_TYPE_VIP  = 3;



    const LOCK_GAMECOIN_ON = 1;
    const LOCK_GAMECOIN_OFF = 0;


    const GIFTCOIN_NUM = 100000;

    const GAME_LOCK_TIMEOUT = 172800;

	public $status = [
		self::STATUS_ON => '启用',
		self::STATUS_OFF => '禁用'
	];

    public $userTypes = [
        self::USER_TYPE_VISITOR => '游客',
        self::USER_TYPE_GENERAL => '普通用户',
        self::USER_TYPE_VIP => 'VIP'

    ];


    public $lock = [
        self::LOCK_GAMECOIN_ON => '是',
        self::LOCK_GAMECOIN_OFF => '否'
    ];


    public function findByInviation($inviation_code){

       $res =  self::where(['invitation_code' => $inviation_code])->find();

       return $res;

    }

    /**
     * 生成邀请码
     */

    public function createInvitationCode(){

        do{
           $invitation_code = getMonogram();
        }while(self::where(['invitation_code' => $invitation_code])->find());

        return $invitation_code;

    }

    public function bindPhone($mobile,$header,$utid){

        $where['devid'] = $header['uuid'];
        $save['mobile'] = $mobile;
        $save['update_time'] = time();

        if($utid == self::USER_TYPE_VISITOR){
            $save['utid'] = self::USER_TYPE_GENERAL;
        }

        $res = self::where($where)->save($save);

        if($res){
            return true;

        }else{
              return false;
        }

    }


    public function getUserInfoById($id){
        $res = self::where(['id' => $id])->find();
        return $res;
    }

    public function getUserInfoByUniId($uni_id){
        $res = self::where(['uni_id' => $uni_id])->find();
        return $res;
    }

    public function CheckBindMobile($mobile){
        $res = self::where(['mobile' => $mobile])->find();
        return $res;
    }
    public function CheckBindUUid($uuid){
        $res = self::where(['devid' => $uuid])->find();
        return $res;
    }
    /**
     * @param $mobile
     *
     */
    public function findByMobile($mobile){

        $res = self::where(['mobile' => $mobile])->find();
        return $res;
    }

    public function createToken($uuid,$data){
        $redis = Datasource::getRedis('instance1');
        //token对照表
         $token_list = $redis->hgetall($data['uni_id']);

         foreach ($token_list as $k => $v){
             if(time() > $v){
                  $redis->hdel($data['uni_id'],$k);
                  unset($token_list[$k]);
             }
         }
//            if(count($token_list) >= 5){
//                    return 'token_limit';
//            }

            $token_key = self::createTokenKey($uuid);

            if(!($redis->hget($data['uni_id'],$token_key)))
                $redis->hset($data['uni_id'], $token_key, time() + C('TOKEN_TIMEOUT'));


            $redis->pipeline();
            foreach($data as $k=>$v){
                $redis->hset($token_key,$k,$v);
            }

            $redis->EXPIRE($token_key,C('TOKEN_TIMEOUT'));
            $res = $redis->exec();
            if(!$res){
                  return false;
              }

          return $token_key;

    }

    /**
     * @param $uuid
     * @return string
     */
    public function createTokenKey($uuid){

        do{
            $token =salt(2).md5(C('REDIS_COMMON_PREFIX').$uuid).uniqid(true);
        }while(S($token));

        return $token;
    }

    /*
     *获取 vip时间
     */
    public function getVipData($expire){
         $end_time = 0;
         if($expire){
             $end_time = $expire-time();
         }

         $end_time = ($end_time >0)?:false;
        return $end_time;
    }

    public function createUinId($uuid){

        do{
            $uin_id = md5($uuid.uniqid(true)).salt(3);
        }while(self::where(['devid' => $uin_id])->find());
        return $uin_id;
    }
    /**通过uuid查询
     * @param $uuid
     */
    public function findByUUid($uuid){

        $res = self::where(['devid' => $uuid])->find();

        return $res;
    }

//_______________________________________________________
    public function register($devid, $mobile="")
    {
        $username = "";
        try {
            $devExist = $this->where(['username'=>$devid])->count();
            $mobileExist = $this->where(['username'=>$mobile])->count();
            if ($mobileExist > 0)
            {
                $username = $mobile;
            } elseif ($devExist > 0) {
                $username = $devid;
                if (!empty($mobile))
                {
                    $id = $this->where(['username'=>$username])->getField('id');
                    $username = $mobile;
                    $this->where(['id'=>$id])->save(['username'=>$username]);
                }   
            } else {
                $username = empty($mobile) ? $devid : $mobile;
                $time = time();
                $data = [
                    'username' => $username,
                    'devid' => $devid,
                    'expire' => 0,
                    'cost' => 0,
                    'create_at' => $time,
                    'mark' => 'app',
                    'guser' => $this->createGuser($devid, $time),
                ];
                $this->add($data);
            }
        } catch (\Exception $e) {
            //\Think\Log::write($e->getMessage());
        }

        $info = $this->where(['username'=>$username])->find();
        return $info ? :[];
    }

    /**
     * 刷新token
     * @param $username
     * $param $logDevid
     * @return string
     */
    public function setToken($username, $logDevid)
    {
        $token = md5($username);
        $userInfo = $this->getToken($token);
        if (empty($userInfo))
        {
            $userInfo = $this->where(['username'=>$username])->find();
        }
        $userInfo['logDevid'] = $logDevid;
        S("T" . $token, $userInfo);
        return $token;
    }

    public function resetToken($username)
    {
        $token = md5($username);
        $userInfo = $this->getToken($token);
        $logDevid = "";
        if (!empty($userInfo))
        {
            $logDevid = $userInfo['logDevid'];
        }
        $userInfo = $this->where(['username'=>$username])->find();
        $userInfo['logDevid'] = $logDevid;
        S("T" . $token, $userInfo);
    }

    public function getToken($token)
    {
        return S("T" . $token) ? : [];
    }

    public function checkToken($token, $logDevid)
    {
        $userInfo = $this->getToken($token);
        if (!empty($userInfo) && $userInfo['logDevid'] == $logDevid)
        {
            return true;
        }
        return false;
    }

	public function checkCode($code)
    {
        $key = $this->checkCodeKey($code);
        return S($key) ? : "";
    }

    public function setCode($code)
    {
    	S($this->codeKey($code), 1, 300);
    }

    public function codeKey($code)
    {
        return "code_" . $code;
    }

	public function checkMobile($mobile)
    {
        if (strlen($mobile) > 6 && preg_match("/^\d+\d$/is", $mobile, $match))
        {
            return true;
        }

        return false;
    }

    /**
     * 存储mobile－code
     * @param $mobile
     * @param $code
     * @return bool
     */
    public function setSms($mobile, $code)
    {
        $key = $this->getSmsKey($mobile);
        $ttl = D('SysConfig')->getValue('SMS_TTL') ? : 300;
        $ttl = (int)$ttl;
        S($key, $code, $ttl);
    }

    public function getSms($mobile)
    {
        $key = $this->getSmsKey($mobile);
        return S($key) ? : "";
    }

    public function getSmsKey($mobile)
    {
        return "sms_" . $mobile;
    }

    /**
     * 判断发送短信是否超限
     * @param $devid
     * @return bool
     */
    public function checkSmsOverLimit($devid)
    {
        $limit = D('SysConfig')->getValue('SMS_SEND_LIMIT') ? : 10;
        $key = $this->getSmsLimitKey($devid);
        if (S($key) < $limit)
        {
            return false;
        }
        return true;
    }

    public function setSmsLimit($devid)
    {
        $key = $this->getSmsLimitKey($devid);
        $count = intval(S($key));
        $count++;
        S($key, $count, strtotime("tomorrow") - time());
    }

    public function getSmsLimitKey($devid)
    {
        return "sms_limit_" . $devid;
    }

    /**
     * interval
     * @param $mobile
     * @return bool
     */
    public function checkSmsInterval($mobile)
    {
        $key = "sms_intv_" . $mobile;
        if (S($key))
        {
            return false;
        }
        return true;
    }

    /**
     * @param $mobile
     */
    public function setSmsInterval($mobile)
    {
        $key = "sms_intv_".$mobile;
        $intv = D('SysConfig')->getValue('SMS_SEND_INTERVAL') ? : 60;
        $intv = (int)$intv;
        S($key, 1, $intv);
    }

    public function createGuser($devid, $createAt)
    {
        return md5($devid . intval($createAt) . uniqid());
    }

    public function setGtoken($guser, $uid)
    {
        $token = strtoupper(md5($guser . time()));
        S("G" . $token, $guser);
        S($guser, ['gtoken'=>"G" . $token, 'uid'=>$uid]);
        return $token;
    }

    public function getGtoken($token)
    {
        return (string)S("G" . $token);
    }

    public function getGuser($guser)
    {
        return S($guser) ? : [];
    }

    public function delGtokenByToken($token)
    {
        S("G" . $token, null);
    }

    public function delGtokenByGuser($guser)
    {
        $gtoken = S($guser);
        if (!empty($gtoken))
        {
            S($gtoken, null);
        }
    }

    public function setGameLockTimeout($uid)
    {
        $redis = \Think\Cache::getInstance();
        $key = $this->getGameLockTimeoutKey();
        $redis->hset($key, $uid, time());
    }

    public function delGameLockTimeout($uid)
    {
        $redis = \Think\Cache::getInstance();
        $key = $this->getGameLockTimeoutKey();
        $redis->hdel($key, $uid);
    }

    public function getGameLockTimeoutKey()
    {
        return "game_lock";
    }
}