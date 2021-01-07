<?php
namespace Helper;

/**
 * 邮箱发送工具
 * 
 * 用法:
 * 
 * @author shuhai
 */
class Email
{
	const SUCCESS   = 0;
	const ERROR_001 = "邀请码生成成功，但系统邮件未配置，无法发送邮件";
	const ERROR_002 = "SMTP发送失败";
	
	/**
	 * 发送邮件
	 * @param string $send_to_email 要发送到的邮箱地址
	 * @param string $subject 邮件标题
	 * @param string $content 邮件内容
	 * @param string $send_from_email 代发邮件的邮箱地址
	 * @param string $attachments 附件列表
	 */
	public function send($send_to_email, $subject, $content, $send_from_email=null, $attachments=null)
	{
		$smtp = include CONF_PATH."email.php";
			
		if(empty($smtp["SMTP"]) || !is_array($smtp))
		{
			//D("SysErrorLog")->log($send_to_email . self::ERROR_001);
			return self::ERROR_001;
		}

		$transport = \Swift_SmtpTransport::newInstance($smtp["SMTP"]["SMTP_HOST"], $smtp["SMTP"]["SMTP_PORT"]);
		$transport->setUsername($smtp["SMTP"]["SMTP_USER"]);
		$transport->setPassword($smtp["SMTP"]["SMTP_PASSWORD"]);
			
		$mailer  = \Swift_Mailer::newInstance($transport);
		$message = \Swift_Message::newInstance();
		$message->setFrom(array($smtp["SMTP"]["SMTP_FROM"] => $smtp["SMTP"]["SMTP_NAME"]));
		$message->setTo($send_to_email);
		$message->setSubject($subject);
		$message->setBody($content, 'text/html', 'utf-8');

		try{
			$mailer->send($message);
			return self::SUCCESS;
		} catch (\Exception $e) {
			$msg = '邮件发送失败: ' . $e->getMessage();
			//D("SysErrorLog")->log($send_to_email . $msg);
			return $msg;
		}
	}
}