<?php


use Phinx\Migration\AbstractMigration;

class AddValues extends AbstractMigration
{
    public function change()
    {
        $sql = "insert into `sys_config` values (null, 'PAYMENT_BACK_URL', 'input', '', 'http://xiaoshuo.enjoynut.cn/api.php?req=notify', '支付平台推送订单地址', '', 'string', 'http://xiaoshuo.enjoynut.cn/api.php?req=notify', 1540543918,1540543918,1);";
        $sql .= "insert into `sys_config` values (null, 'SHARE_TIME_INTERVAL', 'input', '', 900, '分享间隔，单位秒，默认900秒', '', 'digits', 900, 1534166250,1534166250,1);";
        $sql .= "insert into `sys_config` values (null, 'SHARE_TIMES_LIMIT', 'input', '', 3, '当天分享次数上限，默认3', '', 'digits', 3, 1534166250,1534166250,1);";
        $sql .= "insert into `sys_config` values (null, 'SMS_SEND_INTERVAL', 'input', '', 60, '短信发送间隔，单位秒，默认60秒', '', 'digits', 900, 1534166250,1534166250,1);";
        $sql .= "insert into `sys_config` values (null, 'SMS_SEND_LIMIT', 'input', '', 3, '短信发送次数上限，默认3', '', 'digits', 3, 1534166250,1534166250,1);";
        $sql .= "insert into `sys_config` values (null, 'SMS_TTL', 'input', '', 300, '短信验证码有效期，单位秒，默认300', '', 'digits', 300, 1534166250,1534166250,1);";
        $this->execute($sql);
    }
}
