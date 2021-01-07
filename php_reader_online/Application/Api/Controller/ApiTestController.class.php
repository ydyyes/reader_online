<?php

namespace Api\Controller;

class ApiTestController extends IndexController
{       
    public function getData()
    {
    	//测试负载均衡以后的IP是否正常
        $host = gethostname();
        $host = false === $host ? "" : $host;
        $result = ['resultStatus'=>1, 'allCount'=>1, "get_ip_address"=>$this->get_ip_address(), "get_client_ip"=>get_client_ip(), "host"=>$host];
        return $result;
    }
    
	public function get_ip_address()
	{
		$field = array (
				'HTTP_CLIENT_IP',
				'HTTP_CF_CONNECTING_IP',
				'HTTP_X_FORWARDED_FOR',
				'HTTP_X_FORWARDED',
				'HTTP_X_CLUSTER_CLIENT_IP',
				'HTTP_FORWARDED_FOR',
				'HTTP_FORWARDED',
				'REMOTE_ADDR' 
		);
		foreach ( $field  as $key ) {
			if (array_key_exists ( $key, $_SERVER ) === true) {
				foreach ( explode ( ',', $_SERVER [$key] ) as $ip ) {
					$ip = trim ( $ip );
					
					if (filter_var ( $ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE ) !== false) {
						return $ip;
					}
				}
			}
		}
	}
}