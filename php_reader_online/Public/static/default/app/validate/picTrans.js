$(document)
		.ready(
				function() {
					if ($(".regform")) {
						$.formValidator.initConfig({
							theme : "126",
							submitOnce : true,
							formID : "regform",
							onError : function(msg) {
								alert(msg);
							},
							submitAfterAjaxPrompt : '有数据正在异步验证，请稍等...'
						});
						$("#us")
								.formValidator(
										{
											onShowFixText : "6~12个字符，包括字母、数字、下划线，以字母开头，字母或数字结尾",
											onShowText : "请输入用户名",
											onShow : "请输入用户",
											onCorrect : "该用户名可以注册"
										})
								.inputValidator({
									min : 6,
									max : 12,
									onError : "你输入的用户长度不正确"
								})
								.regexValidator({
									regExp : "username",
									dataType : "enum",
									onError : "用户名格式不正确"
								})
								.ajaxValidator(
										{
											dataType : "html",
											async : true,
											url : "http://www.51gh.net/chkuser.aspx?act=ok",
											success : function(data) {
												if (data.indexOf("此用户名可以注册!") > 0)
													return true;
												if (data
														.indexOf("此用户名已存在,请填写其它用户名!") > 0)
													return false;
												return false;
											},
											buttons : $("#button"),
											error : function(jqXHR, textStatus,
													errorThrown) {
												alert("服务器没有返回数据，可能服务器忙，请重试"
														+ errorThrown);
											},
											onError : "该用户名不可用，请更换用户名",
											onWait : "正在进行合法性校验，请稍候..."
										});
						$("#email")
								.formValidator(
										{
											onShowFixText : "6~18个字符，包括字母、数字、下划线，以字母开头，字母或数字结尾",
											onShow : "请输入邮箱",
											onFocus : "邮箱6-100个字符,输入正确了才能离开焦点",
											onCorrect : "恭喜你,你输对了",
											defaultValue : "@"
										})
								.inputValidator({
									min : 6,
									max : 100,
									onError : "你输入的邮箱长度非法"
								})
								.regexValidator(
										{
											regExp : "^([\\w-.]+)@(([[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.)|(([\\w-]+.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(]?)$",
											onError : "你输入的邮箱格式不正确"
										});
						$("#password1").formValidator({
							onShowFixText : "6~16个字符，包括字母、数字、特殊符号，区分大小写",
							onShow : "请输入密码",
							onFocus : "至少1个长度",
							onCorrect : "密码合法"
						}).inputValidator({
							min : 6,
							max : 16,
							empty : {
								leftEmpty : false,
								rightEmpty : false,
								emptyError : "密码两边不能有空符号"
							},
							onError : "密码长度错误"
						}).passwordValidator({
							compareID : "us"
						});
						$("#password2").formValidator({
							onShowFixText : "请再次输入密码",
							onShow : "输再次输入密码",
							onFocus : "至少1个长度",
							onCorrect : "密码一致"
						}).inputValidator({
							min : 1,
							empty : {
								leftEmpty : false,
								rightEmpty : false,
								emptyError : "重复密码两边不能有空符号"
							},
							onError : "重复密码不能为空"
						}).compareValidator({
							desID : "password1",
							operateor : "=",
							onError : "2次密码不一致"
						});
						$("#realname").formValidator({
							onShowFixText : "请填写真实姓名，请勿填写昵称",
							onShow : "请填写真实姓名",
							onFocus : "请填写真实姓名",
							onCorrect : " "
						}).inputValidator({
							min : 4,
							max : 10,
							onError : "请填写真实姓名"
						});
						$("#province").formValidator({
							onShowFixText : "请选择所在地",
							onFocus : "请选择所在地",
							defaultValue : "0",
							onCorrect : " "
						}).inputValidator({
							min : 1,
							onError : "请选择正确省份!"
						});
						$("#tel").formValidator({
							onShowFixText : "密码遗忘或被盗时，可通过手机短信取回密码",
							onShow : "请输入手机号码",
							onFocus : "手机的长度必须是11位",
							onCorrect : "手机合法"
						}).inputValidator({
							min : 11,
							max : 11,
							onError : "手机号码必须为11位"
						}).regexValidator({
							regExp : "mobile",
							dataType : "enum",
							onError : "手机的格式不正确"
						});
						$("#phone")
								.formValidator({
									empty : true,
									onShowFixText : "请输入固定电话，格式如010-58236918",
									onShow : "请输入固定电话，格式如010-58236918",
									onFocus : "请输入固定电话，格式如010-58236918",
									onCorrect : " "
								})
								.regexValidator(
										{
											regExp : "^(([0\\+]\\d{2,3}-)?(0\\d{2,3})-)?(\\d{7,8})(-(\\d{3,}))?$",
											onError : "电话格式不正确"
										});
						$("#qq").formValidator({
							empty : true,
							onShowFixText : "请填写常用QQ号码，方便及时联系",
							onShow : "请填写常用QQ号码，方便及时联系",
							onFocus : "请填写常用QQ号码，方便及时联系",
							onCorrect : " "
						}).regexValidator({
							regExp : "qq",
							dataType : "enum",
							onError : "QQ号码格式不正确"
						});
						$("#website").formValidator({
							onShowFixText : "如：www.eoemarket.com",
							onShow : "如：www.eoemarket.com",
							onFocus : "如：www.eoemarket.com",
							onCorrect : " "
						});
						$("#idcard").formValidator({
							onShowFixText : "请上传身份证复印件",
							onShow : "请上传身份证复印件",
							onFocus : "请上传身份证复印件",
							onCorrect : " "
						}).functionValidator(
								{
									fun : function(val, elem) {
										if ($("#isrenzheng").attr("checked")
												&& val == "") {
											return "请上传身份证复印件";
										} else {
											return true;
										}
									}
								});
						$("#shouquan").formValidator({
							onShowFixText : "请上传授权书扫描件",
							onShow : "请上传授权书扫描件",
							onFocus : "请上传授权书扫描件",
							onCorrect : " "
						}).functionValidator(
								{
									fun : function(val, elem) {
										if ($("#isrenzheng").attr("checked")
												&& val == "") {
											return "请上传授权书扫描件";
										} else {
											return true;
										}
									}
								});
						$("#isrenzheng").click(function() {
							$(".renzhengziliao").toggle()
						});
					}
				})