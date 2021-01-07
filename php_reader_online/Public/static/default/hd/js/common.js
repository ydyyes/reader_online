//验证码重载
$('.codeimg,.vcodez').click(function() {
	$(".codeimg").attr('src', $(".codeimg").data('url')+'?'+Math.random());
});

//login页面、邀请码页面注册表单验证
$("#registForm").Validform({
	btnSubmit:"#regist",
	tiptype:function(msg,o,cssctl){
		if(!o.obj.is("form")){
			var objtip=o.obj.next(".Validform_checktip");
			var left=o.obj.offset().left,
				top=o.obj.offset().top,
				width = o.obj.width()
			$(objtip).css({
				left: left+220,
				top: top+14,
				width:width-200
			});
			cssctl(objtip,o.type);
			objtip.text(msg);
			var infoObj= objtip
			if(o.type==2){
				infoObj.fadeOut(200);
			}else{
				if(infoObj.is(":visible")){return;}
				infoObj.hide();
				infoObj.css({
					left:left+170,
					top:top-45
				}).show().animate({
					top:top-35	
				},200);
			}
		}
	},
	usePlugin:{
		passwordstrength:{
			minLen:6,
			maxLen:18,
			trigger:function(obj,error){
				if(error){
				}else{
					obj.parents("td").next().find(".info").hide();
				}
			}
		}
	},
	callback:function(data){
		$.ajax({
			url: $("#registForm").attr("action"),
			type: "POST",
			data: $("#registForm").serializeArray(),
			dataType: 'json',
			success: function (res) {
				if(res.status == 1){
					//如果是在邀请码页面，则跳转到第二步
					if($(".invCodeRegist").length == 1)
						gotoStep(2);
					else{
						$.getJSON( "/user/profile_json", function( data ) {
							$(".registSuccessBox h1").html('欢迎，'+data.username);
							$(".registSuccessBox .headBox img").attr('src', data.avatar);
						});
						setlocal(3, "/user/index?action=regsuccess", "localHref");
					}
				}else if(res.status == 0){
					errorMsg(res.info)
				}else{
					errorMsg('服务器出错了，请重试')
				}
			},
			error:function(res){
				errorMsg('服务器出错了，请重试')
			}
		});
		return false;
	}
});

//登陆
$(".loginbutton").click(function(){
	$.ajax({
		url: $("#loginForm").attr("action"),
		type: "POST",
		data: $("#loginForm").serializeArray(),
		dataType: 'json',
		success: function (res) {
			if(res.status == 1){
				$(".registSuccessBox h1").html('欢迎，' + res.username);
				$(".registSuccessBox .headBox img").attr('src', res.avatar);
				setlocal(3, "/user/index?action=loginsuccess", "localHref");
			}else if(res.status == 0){
				errorMsg(res.info)
				if(res.vcodeShow == 1) {
					$('.codeimg').click();
					$(".vCode").show();
				}
					
			}else{
				errorMsg('服务器出错了，请重试')
			}
		},
		error:function(res){
			errorMsg('服务器出错了，请重试')
		}
	});
});	

//一些显示隐藏
$(".registGo").click(function(event) {
	$(".login").hide()
	$(".register").show()
});
$("#loginGo").click(function(event) {
	$(".register").hide()
	$(".login").show()
});
$("#wicode").click(function(event) {
	$(".Validform_checktip").hide();
	$("#tipBox").toggle('fast')
});
$(".closeTipBox").click(function(event) {
	$("#tipBox").hide()
});
$(".closePage").click(function(event) {
	$(".invCodeBg").hide()
	$(".invCode").hide()
});
$(".howGet").click(function(event) {
	$(".invCodeBg").show()
	$(".invCode").show()
	$("#tipBox").hide()
});
$(".stepLi a").click(function(event) {
	var i = $(this).index()
	chengeStepImg(i)
	chengeStepLi(i)
});
// 首页邀请码帮助轮播
var stepPage = 0
$(".stepPage a").click(function(event) {
	var ti = $(this).index(),
		i = stepPage
	if (ti == 0) {
		if(i>0){
			i--
		}else{
			i = 3
		}
	}else{
		if(i < 3){
			i++
		}else{
			i = 0
		}
	}
	chengeStepImg(i)
	chengeStepLi(i)
});
function chengeStepImg(i){
	$(".stepImg li").eq(i).show().siblings('li').hide()
	stepPage = i
}
function chengeStepLi(i){
	$(".stepLi a").eq(i).addClass('this').siblings('a').removeClass('this')
}
//登陆成功跳转
function setlocal(count,local,classn){
	$(".registSuccessBox").show()
	$(".registSuccess").show()
	$(".localHrefN").attr('href', local);
	window.setTimeout(function(){ 
        count--; 
        if(count > 0) {
        	$(classn+' i').html(count)
            setlocal(count,local,classn); 
        } else { 
            location.href=local; 
        } 
    }, 1000); 
}

// 邀请码申请 证件照片上传
$(".codeImgBox,.upImgButton").click(function(event) {
	$("#upImgInput").click()
});
$("#upImgInput").change(function () {
	if (this.type === 'file' && this.files && this.files.length > 0) {
		insertFilesup(this.files);
	}
});
var insertFilesup = function (files) {
	var formdata = new FormData();
	$.each(files, function (idx, fileInfo) {
		if (/^image\//.test(fileInfo.type)) {
			formdata.append("files", fileInfo);
		}
	});
	$.ajax({
		url: "/user/credential_file",
		type: "POST",
		data: formdata,
		processData: false,
		contentType: false,
		dataType: 'json',
		success: function (res) {
			if (res.status == 1) {
				succUp(res.url);
			}else{
				errorMsg(res.info + "，请重新上传。")
			}
		},
		error: function (){
			errorMsg('上传失败，请重试，或联系我们')
		}
	});
}
function succUp(url){
	$(".upImgButton").hide()
	$(".codenext").css('display', 'block').click(function(){gotoStep(3)});
	$(".codeUploadImg h2").html('上传成功，可点击图片重新上传，或点击[下一步]')
	$(".codeImgBox").html('<img src="'+url+'" alt="">')
}
function gotoStep(step){
	$(".codeSpeed span").removeClass('this')
	$(".codeSpeed span:lt("+step+")").addClass('this')
	$(".stepGroup").hide();
	$(".stepGroup").eq(step-1).show();
	return true;
}
// 选择学校
var Aselect = '<option>请选择学校所在地区</option>';
allUnivList.forEach(function(area, id) {
    Aselect += "<option value="+ area.id + ">" + area.name + "</option>";
});
$("#area").html(Aselect).change(function(event) {
	makeSchool($(this).val())
});
function makeSchool(a) {
    var Bselect = '<option>请选择学校</option>';
    allUnivList[a - 1].univs.forEach(function(school){
        Bselect += "<option value="+ school.id + ">" + school.name + "</option>";
    });

    $("#school").html(Bselect);
}

//已上传了证件则进行显示
if( $(".codeImgBox").attr('default') != undefined && $(".codeImgBox").attr('default').length > 5) succUp($(".codeImgBox").attr('default'));

//获取邀请码时，完善资料
$("#profileForm").Validform({
	btnSubmit:"#profileSubmit",
	tiptype:function(msg,o,cssctl){
		if(!o.obj.is("form")){
			var objtip=o.obj.next(".Validform_checktip");
			var left=o.obj.offset().left,
				top=o.obj.offset().top,
				width = o.obj.width()
				console.log(top)
			$(objtip).css({
				left: left+90,
				top: top+14,
				width:120
			});
			cssctl(objtip,o.type);
			objtip.text(msg);
			var infoObj= objtip
			if(o.type==2){
				infoObj.fadeOut(200);
			}else{
				if(infoObj.is(":visible")){return;}
				infoObj.hide();
				infoObj.css({
					left:left+170,
					top:top-45
				}).show().animate({
					top:top-35	
				},200);
			}
		}
	},
	callback:function(data){
		$.ajax({
			url: $("#profileForm").attr("action"),
			type: "POST",
			data: $("#profileForm").serializeArray(),
			dataType: 'json',
			success: function (res) {
				if(res.status == 1){
					setlocal(3, "/user/index?action=regsuccess", "localHref");
				}else if(res.status == 0){
					errorMsg(res.info)
				}else{
					errorMsg('服务器出错了，请重试')
				}
			},
			error:function(res){
				errorMsg('服务器出错了，请重试')
			}
		});
		return false;
	}
});
//for devleopment
function errorMsg(msg){
	$(".errorbox").html(msg).show()
	setTimeout(function(){$(".errorbox").hide()},2000)
}
function succMsg(msg){
	$(".succbox").html(msg).show()
	setTimeout(function(){$(".succbox").hide()},2000)
}
	//个人中心头部信息提示js
	//如果有消息 给 ‘tip’ 加clss anTip
	$(".tip").addClass('anTip')
	//ajax  获取 消息数 插入页面
	$(".tip span").html('( 2 )')

	$(".tip").click(function(event) {
		$(this).toggleClass('tipThis');
	})
	//如果没有消息 插入内容
	//$(".tipMassage").html('<div class="noMassage">没有消息~</div>')


//编辑个人资料
$(".setbasic").click(function(event) {
	$("#setbasicBox .setMateRight").hide()
	$("#setbasicBox .setedit").show()
});
$("#setbasicBox .editcancel").click(function(event) {
	$("#setbasicBox .setMateRight").show()
	$("#setbasicBox .setedit").hide()
});
$("#setbasicBox .editsave").click(function(event) {
	$.ajax({
		url: $("#profileForm").attr("action"),
		type: "POST",
		data: $("#profileForm").serializeArray(),
		dataType: 'json',
		success: function (res) {
			if(res.status == 1){
				errorMsg(res.info)
				setTimeout(function(){window.location.reload();},2001)
			}else if(res.status == 0){
				errorMsg(res.info)
			}else{
				errorMsg("服务器出错了，请重试")
			}
		},
		error:function(res){
			errorMsg('服务器出错了，请重试')
		}
	});
});

// $(".setL .setLb").click(function(event) {
// 	var i = $(this).index()
// 	$(this).addClass('setLbt').siblings().removeClass('setLbt')
// 	$(".setR form").eq(i).show().siblings().hide()

// });
//认证中心 认证评分
// var current = 0;
// $(".reScore").click(function(event) {
// 	$(".score").html("0分")
// 	$(".barBoxn").css('width', '0%');
// 	$(".reScore").html("重新检测");
// });



//认证中心
$(".closeAuthbox").click(function(event) {
	$(".authbox").hide()
});
function countdownButtom(s,c,n,oc,cc){
	c.addClass(oc).html(s+n)
	c.removeClass(cc)
	window.setTimeout(function(){ 
        s--; 
        if(s > 0) {
            countdownButtom(s,c,n,oc,cc)
        } else { 
			c.addClass(cc)
            c.removeClass(oc).html('重新发送')
        } 
    }, 1000); 
}
//邮箱验证相关
$("#emailAuth").click(function(event) {
	$(".authbox").hide()
	$("#emailauthbox").show()
});

$(".emailauthbutton").click(function(event) {
	var email = $("#emailAuthinput")
	if (email.val()) {
		// ajax发送确认邮件
		$.ajax({
			url: '/safety/email',
			type: 'POST',
			dataType: 'json',
			data: {'verify_type': 'email','veriy_content':email.val(),'verify_value':''},
		})
		.done(function() {
			console.log("success");
		})
		.fail(function() {
			console.log("error");
		})
		.always(function() {
			console.log("complete");
		});

		//countdownButtom(59,$(".emailauthbutton"),' 秒后继续','authbuttonok','emailauthbutton')
		//如果检测到已经验证
		// $(".emailauthbutton").hide();
		// $(".authsucc").show();
	}else{
		email.attr('placeholder', '请输入邮箱').addClass('inputerror')
	}
});


// 手机验证相关
$("#telAuth").click(function(event) {
	$(".authbox").hide()
	$("#telauthbox").show()
});
$(".gettelcodebuttom").click(function(event) {
	var tel = $("#telAuthinput")
	if (tel.val()) {
		// ajax发送验证码
		countdownButtom(59,$(".gettelcodebuttom"),' 秒后继续','authbuttonok','gettelcodebuttom')
	}else{
		tel.attr('placeholder', '请输入手机号码').addClass('inputerror')
	}
});

$(".telcodebuttom").click(function(event) {
	var code = $("#telcode")
	if (code.val()) {
		// ajax发送确认验证码
		//通过后
		$(".authbox").hide()
		succMsg('验证成功')
	}else{
		code.attr('placeholder', '输入验证码').addClass('inputerror')
	}
});

// 手支付宝验证相关
$("#alipayAuth").click(function(event) {
	$(".authbox").hide()
	$("#alipayauthbox").show()
});
$(".getalipaycodebuttom").click(function(event) {
	var alipay = $("#alipayAuthinput")
	if (alipay.val()) {
		// ajax发送验证码
		countdownButtom(59,$(".getalipaycodebuttom"),' 秒后继续','authbuttonok','getalipaycodebuttom')
	}else{
		alipay.attr('placeholder', '请输入手机号码').addClass('inputerror')
	}
});

$(".alipaycodebuttom").click(function(event) {
	var code = $("#alipaycode")
	if (code.val()) {
		// ajax发送确认验证码
		//通过后
		$(".authbox").hide()
		succMsg('验证成功')
	}else{
		code.attr('placeholder', '请输入金额').addClass('inputerror')
	}
});


$(".select div").click(function(event) {
	var sdata = $(this).data('select')
	if (sdata) {
		$(".select").hide()
		$('.'+sdata).show()
	};
});

$(".alipaygo").click(function(event) {
	var amountMoney = $("#amountMoney").val(),
		 safetyCode = $("#safetyCode").val()
		 if(!amountMoney){
		 	$("#amountMoney").attr('placeholder', '请输入金额').addClass('inputerror');
		 	return false
		 }else{
		 	$("#amountMoney").attr('placeholder', '').removeClass('inputerror');
		 }
		 if(!safetyCode){
		 	$("#safetyCode").attr('placeholder', '请输入安全码').addClass('inputerror');
		 	return false
		 }
		 $(".succtitle").html('提现成功')
		 $(".succtext").html('你提取的红币将于今日内到账，请注意查收')
		 $(".successbg").show()
		 $(".successbox").show()
		 $(".reloadextra").hide()
});
var M = 100
$("#amountMoney").keyup(function(event) {
	var val = $(this).val()
	$(this).val(val.replace(/\D/g,''))
	var val = $(this).val()
	if (val > M) {
		val = M
		$(this).val(val)
		errorMsg('最多只能提现'+val+'元')
	};
	$(".alipayB").html(val*10+' 红币')
});
$(".goselect").click(function(event) {
		$(".select").show()
		$(".alipaybox").hide()
		$(".telbox").hide()
});
if(M >= 100){
	$(".telM4").show()
	$(".telM3").show()
	$(".telM2").show()
	$(".telM1").show()
}else if(M >= 50){
	$(".telM3").show()
	$(".telM2").show()
	$(".telM1").show()
}else if(M >= 20){
	$(".telM2").show()
	$(".telM1").show()
}else if(M >= 10){
	$(".telM1").show()
}else if(M < 10){
	$(".telM").html('余额不足')
}


$("#telnumber").change(function(event) {
	var tel = $(this).val().substr(0, 7)
	$.ajax({
		url: '/api/mobile_check',
		type: 'GET',
		dataType: 'json',
		data: {mobile: tel},
		success:function(data){
			$(".teltip").html(data.info);
		}
	})
});
$(".telM input").change(function(event) {
	var val= $(this).val()
	$(".telB").html(val*10+' 红币')
});

$(".telgo").click(function(event) {
	var telnumber = $("#telnumber").val(),
		 telsafetyCode = $("#telsafetyCode").val()
		 if(!telnumber){
		 	$("#telnumber").attr('placeholder', '请输入手机号').addClass('inputerror');
		 	return false
		 }else{
		 	$("#telnumber").attr('placeholder', '').removeClass('inputerror');
		 }
		 if(!telsafetyCode){
		 	$("#telsafetyCode").attr('placeholder', '请输入安全码').addClass('inputerror');
		 	return false
		 }
		 $(".succtitle").html('充值成功')
		 $(".succtext").html('你充值的话费将于今日内到账，请注意查收')
		 $(".successbg").show()
		 $(".successbox").show()
		 $(".reloadextra").show()
});

$(".reloadextra").click(function(event) {
	window.reload;
});
$(".serch").hover(function() {
	$(".derchBox input")[0].focus();
});





