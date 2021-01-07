<?php

namespace Helper;

class Alipay
{
	//应用ID
	public $appId = "2018111462163306";
	
	//私钥文件路径
	public $rsaPrivateKeyFilePath;

	//私钥值
	public $rsaPrivateKey = "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCeaMcznvsmE2tyfrbuErXQDGPv+RRhEi7QtTi+PKPRRHU2sd/E0SvTrfR3Wh23SLYBw/aukncxFfs8lq6A/SGIOsLYGdWimM8iWvRHw1rVTRpoIch70T3X85GOIiSN97JgrICAifXoTC9AU5PAfFNCeBALYaMr9JYFUCLAj9yK/mPnNGO7kWVKxsn+U6qrtUAWSrcmhU6Cfg3THm3UZAucmTepkwSjDjrq2hadlMbEYHw3Q6NO1JdWb0Vh6qXBuzy+elb6xD5itioPC14velO7dhcUFsvIdMzEm6EyOZmk6wxnZ6LFprqYvd0Vpr/O7WOTl9azx1YyozeMmGjdocN/AgMBAAECggEAD062uTFKubI0ttqx2K2sLg+UdLMQGhVEutxYQGHhvq4r2X40znMcFheAQSxPJM/87oy+QL5ckDy8i21QLZzIab6r53APqee0VHCPnIOvOl96BsgE9JoSrNSXozF/cMyXyynAPSuXvLvn8QJii7432Xt6qW7k8rFu8dJ9mTgNqsylX6OUdXO3X2ZJT9pT2gGv2ZdEKanOVAQeT0O8C8rxPPr/wCDKug8EFmLlk/Ih5Ks26UTJtPfOrScbq4YTjjSjJOWhjyGncbxC8RWYWPgKR7+DzVzOpZaCSva0ySlEjoNkPmXXm/L5sHNnoikI+zQ4wszaXNrZVcboqTjqhFyHSQKBgQDXHL0KEy15OHrCJx8m5jp5/kAGBGFZ1BFpDQwO9d1sDNv/HZEJ4SwxiTZVHDVWY/j44ugDlClDRKRy7k8OLHtB8wY3H7Y+rnSgqF6BQY1/khKD7r0rngmGLsQc0tDIm7V6C+6qvurhETSTZGc+XXcQm3KKzVrSroS6csDbwBni4wKBgQC8hOZZK+E9uLumk6wt5ikA5f5AZV2PJUAf4yJdmEVWrn3ZJJ+tHEeS4oJof/g+vrUPx9GUa6lcrmZ/uGC7lrKGWrjyWUmj4yimKxw2HtymP99eZgsAjxtdKatilZMHnbni+DrrQtHGEZPgFY0nIM9MBAFai4tEoftiNteu24STtQKBgQDFTW+6oPJxoDNAh3+UP1Fdea2hlzzvlorNjxEDW9HW/EiAy86vgB/344G5OOFXNuUy63Sha7EZKQmo/Rn3xybay5xkzSpsfbktbqEX71dorkNbTYunSRI1SAnK4jZr+h3PLsifRfPLsetGUa48zp+Z1OqPk2F9omLNXNm19ZIIvwKBgHHthx/gqtCYMZ9royRh8em/FLZqC+6UPnqG05/ohA7siNWPkogVjROxm8n3fFi++8E7quadYc7G/t602JDFc8JKVXbwitZmU4yIhRYX9JTsCNuNo5yE366fnhmH90ElCs+l4EWJLikbOliz7Yf2BhEUYpULu/CQS9GA/zuHIkn5AoGAMYq+lZfhS534K8Rj05kWSKTYGrSuczkcuyuLdSSYhKBjoXxEPhaMgDfijNnrxXonLA8v7WKuaOgo25q6vbYY6py8T4xxDEQ6P1TFy6fKW+1y5Lmzhv6X+douFs0VwkDIHGcxOUGHvvqT++YIcWB+kKEjGsTdJ96TbMkNwSrX+Fw=";

	//使用读取字符串格式，请只传递该值
	public $alipayrsaPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArYdn6EAXqEhS4+ljemuLo5nxgZmbQLM19Vr7cxjWLlep4N04790tygrZaExE9IBA56ypTK7xH2shA97iKfuY+eYK5xoe9eamcddBdH+ZhNw8KVOHH4Ha+pO1LSBej7sKHIwlQ7wUaIub4s3cTUpnFuwFO1dUWjV8b8p4+Byfkz9oWSAUPt17xgOY0xK+ngRecNv2WLOuuWYKrOwNAxkiF+fed4coi8budZiQFIzSpatsr47PpjxWd4sAIMBiOkG0gr0RhUvU/1uwGM9dLkouSKkX81eD3eYISrNIITKziniOaHQkDOJ1HLaJJfXdmGhooe2kyImo3f6HI6m0dKVPGwIDAQAB";

	public function getSignContent($params) {
		ksort($params);

		$stringToBeSigned = "";
		$i = 0;
		foreach ($params as $k => $v) {
			if (false === $this->checkEmpty($v) && "@" != substr($v, 0, 1)) {

				// 转换成目标字符集
				$v = $this->characet($v, 'UTF-8');

				if ($i == 0) {
					$stringToBeSigned .= "$k" . "=" . "$v";
				} else {
					$stringToBeSigned .= "&" . "$k" . "=" . "$v";
				}
				$i++;
			}
		}

		unset ($k, $v);
		return $stringToBeSigned;
	}

	protected function sign($data, $signType = "RSA") {
		if($this->checkEmpty($this->rsaPrivateKeyFilePath)){
			$priKey=$this->rsaPrivateKey;
			$res = "-----BEGIN RSA PRIVATE KEY-----\n" .
				wordwrap($priKey, 64, "\n", true) .
				"\n-----END RSA PRIVATE KEY-----";
		}else {
			$priKey = file_get_contents($this->rsaPrivateKeyFilePath);
			$res = openssl_get_privatekey($priKey);
		}

		($res) or die('您使用的私钥格式错误，请检查RSA私钥配置'); 

		if ("RSA2" == $signType) {
			openssl_sign($data, $sign, $res, OPENSSL_ALGO_SHA256);
		} else {
			openssl_sign($data, $sign, $res);
		}

		if(!$this->checkEmpty($this->rsaPrivateKeyFilePath)){
			openssl_free_key($res);
		}
		$sign = base64_encode($sign);
		return $sign;
	}

	public function generateSign($params, $signType = "RSA") {
		return $this->sign($this->getSignContent($params), $signType);
	}

	//此方法对value做urlencode
	public function getSignContentUrlencode($params) {
		ksort($params);

		$stringToBeSigned = "";
		$i = 0;
		foreach ($params as $k => $v) {
			if (false === $this->checkEmpty($v) && "@" != substr($v, 0, 1)) {

				// 转换成目标字符集
				$v = $this->characet($v, $this->postCharset);

				if ($i == 0) {
					$stringToBeSigned .= "$k" . "=" . urlencode($v);
				} else {
					$stringToBeSigned .= "&" . "$k" . "=" . urlencode($v);
				}
				$i++;
			}
		}

		unset ($k, $v);
		return $stringToBeSigned;
	}

	/**
	 * 校验$value是否非空
	 *  if not set ,return true;
	 *    if is null , return true;
	 **/
	protected function checkEmpty($value) {
		if (!isset($value))
			return true;
		if ($value === null)
			return true;
		if (trim($value) === "")
			return true;

		return false;
	}

	/**
	 * 转换字符集编码
	 * @param $data
	 * @param $targetCharset
	 * @return string
	 */
	function characet($data, $targetCharset) {
		
		if (!empty($data)) {
			$fileType = 'UTF-8';
			if (strcasecmp($fileType, $targetCharset) != 0) {
				$data = mb_convert_encoding($data, $targetCharset, $fileType);
				//				$data = iconv($fileType, $targetCharset.'//IGNORE', $data);
			}
		}


		return $data;
	}
}