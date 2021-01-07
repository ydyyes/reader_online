<?php
/**
 * 菜单配置文件格式
 * $memu["左侧主菜单"] = [
 *		"子菜单"	=>["子菜单中文名", "默认方法", "参数"],
 * ]
 * 
 * 执行 php cli.php menu/make 进行同步
 */
$memu =[];
$memu["渠道管理"] = [
		"SysChannel"			=>["渠道管理", "index"],
		"SysVersion"			=>["版本管理", "index"],
		"SysVersionChannel"		=>["渠道版本", "index"],
		"SysChannelAdmin"		=>["渠道权限", "index"],
];

$memu["系统设置"] = [
		"SysErrorLog"			=>["系统错误管理"],
		"SysConfig"				=>["系统参数字段"],
		"SysConfig "			=>["参数设置", 'setting'],
];

$memu["内容管理"] = [
    "XsCates"			        =>["分类管理", "index"],
    "XsNovels"				    =>["小说管理", "index"],
    "XsSource"			        =>["小说来源管理", "index"],
    "XsRecommend"			    =>["推荐管理", "index"],
    "Ad"                        =>["广告管理", "index"],
    "CarouselMap"               =>["轮播管理", "index"],
    "XsFeedback"                =>["反馈管理", "index"],
    'XsExchangeGold'            =>["金币兑换管理","index"]
];

$memu["账户管理"] = [
    "UserList"			        =>["账户表", "index"],
    "UserGoldExchange"		    =>["用户兑换记录", "index"],
    "UserList"                  =>["后台操作金币记录","adminGoldLog"],
    "UserPaidLogs"              =>["用户充值记录","index"]
   # "UserPaidLog"			    =>["会员充值记录", "index"],
];
$memu["商品管理"] = [
    "ProductList"			    =>["会员商品", "index"],

];

$memu["任务管理"] = [
    "TaskList"                   =>["任务列表", "index"],
    "TaskLog"                    =>["完成任务列表", "index"],
    "YouMiLog"                   =>["有米数据数据列表", "index"],
];

$memu["更新管理"] = [
    "Upgrade"				    =>["更新列表", "index"],
    "ClearCache"                =>["清除缓存", "index"],
];


/*$memu["娱乐管理"] = [
    "Games"                     =>["项目列表", "index"],
    "CoinLog"                   =>["收支记录", "index"],
    "WithdrawLog"               =>["提现管理", "index"],
    "UpdateCoinOrders"          =>["订单管理", "index"],
];*/

/*$memu["统计分析"] = [
    "StatisticChapters"         =>["付费点统计", "index"],
    "StatisticKeywords"         =>["搜索量统计", "index"],
    "StatisticReadtimes"        =>["阅读量统计", "index"],
    "StatisticDloadtimes"       =>["分享渠道下载统计", "index"],
    "StatisticPayment"          =>["付费点渠道统计", "index"],
];*/


return $memu;
