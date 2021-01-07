$(function(){
	$("textarea#edit").yedit({model:'basic', autoSave:true});
	$("a.link-sure").click(function(){
		pos = cursorPosition.get(areaedit);
		cursorPosition.add(areaedit, pos, "[标题](url)");
		$("#myLink").modal("hide");
	});
	$("a.code-sure").click(function(){
		pos = cursorPosition.get(areaedit);
		var cods = "代码";
		cursorPosition.add(areaedit, pos, "```java\n"+cods+"\n```");
		$("#myCode").modal("hide");
	});
	//图片链接
	$("a.img-link").click(function(){
		pos = cursorPosition.get(areaedit);
		cursorPosition.add(areaedit, pos, "![提示内容](url)");
		$("#myImgLink").modal("hide");
	});


	$("a.link-sure").click(function(){
		var title = $("input[name='url-title']").val();
		var url = $("input[name='url']").val();
		if(!title && !url)
			return false;
		pos = cursorPosition.get(areaedit);
		if(!title)
			title = pos.text?pos.text:url;

		$("input[name='url-title']").val(null);
		$("input[name='url']").val(null);
		cursorPosition.add(areaedit, pos, "["+title+"]("+url+")");
		$("#myLink").modal("hide");
	});
	$("a.code-sure").click(function(){
		var language = $("select[name='code-language']").val();
		pos = cursorPosition.get(areaedit);
		var cods = pos.text?pos.text:"代码";
		cursorPosition.add(areaedit, pos, "```"+language+"\n"+cods+"\n```");
		$("#myCode").modal("hide");
	});
	//图片链接
	$("a.img-link").click(function(){
		var title = $("input[name='img-title']").val();
		var url = $("input[name='img-link']").val();
		if(!url)
			return false;

		title = title?title:'图片标题';
		url = url?url:'图片远程地址';
		pos = cursorPosition.get(areaedit);

		$("input[name='img-title']").val(null);
		$("input[name='img-link']").val(null);

		cursorPosition.add(areaedit, pos, "!["+title+"]("+url+")");
		$("#myImgLink").modal("hide");
	});
})
