<?php

namespace Common\Controller;

use SessionHandler;
use think\Exception;

class RedisSession extends SessionHandler
{
    /** @var \Redis */
    protected $handler = null;
    protected $config  = [
        'host'         => '127.0.0.1', // redis主机
        'port'         => 6388, // redis端口
        'password'     => '', // 密码
        'expire'       => 3600, // 有效期(秒)
        'timeout'      => 0, // 超时时间(秒)
        'persistent'   => true, // 是否长连接
        'session_name' => 'sess_', // sessionkey前缀
    ];

    public function __construct($config = [])
    {
        $config = ['host'           => C('REDIS_HOST'),
                   'port'           => C('REDIS_PORT'),
                   'password'       => C('REDIS_PASSWORD')
        ];
        $this->config = array_merge($this->config, $config);
    }

    /**
     * 打开Session
     * @access public
     * @param string $savePath
     * @param mixed  $sessName
     * @return bool
     * @throws Exception
     */
    public function open($savePath, $sessName)
    {


        // 检测php环境
        if (!extension_loaded('redis')) {
            throw new Exception('not support:redis');
        }
        $this->handler = new \Redis;


        // 建立连接
        $func = $this->config['persistent'] ? 'pconnect' : 'connect';
        $this->handler->$func($this->config['host'], $this->config['port'], $this->config['timeout']);

        if ('' != $this->config['password']) {
            $this->handler->auth($this->config['password']);
        }
        return true;
    }

    /**
     * 关闭Session
     * @access public
     */
    public function close()
    {
        $this->gc(ini_get('session.gc_maxlifetime'));
        $this->handler->close();
        $this->handler = null;
        return true;
    }

    /**
     * 读取Session
     * @access public
     * @param string $sessID
     * @return string|string
     */
    public function read($sessID)
    {
        $res=$this->handler->get($this->config['session_name'] . $sessID);
        $res=!empty($res)?$res:'';
        return $res;
    }

    /**
     * 写入Session
     * @access public
     * @param string $sessID
     * @param String $sessData
     * @return bool
     */

    public function write($sessID, $sessData)
    {
        if ($this->config['expire'] > 0) {

            return $this->handler->setex($this->config['session_name'] . $sessID, $this->config['expire'], $sessData);
        } else {

            return $this->handler->set($this->config['session_name'] . $sessID, $sessData);
        }
    }

    /**
     * 删除Session
     * @access public
     * @param string $sessID
     * @return bool|void
     */
    public function destroy($sessID)
    {
        $this->handler->delete($this->config['session_name'] . $sessID);
    }

    /**
     * Session 垃圾回收
     * @access public
     * @param string $sessMaxLifeTime
     * @return bool
     */
    public function gc($sessMaxLifeTime)
    {
        return true;
    }
}
