/**
 * jQuery 简约版编辑器插件
 * Author: allenqinhai@gmail.com
 * Time  : 2012/12/1
 * eoeAndroid 开发者社区
 */
var areaedit,
	interval,
	pos;
(function($){
	$.fn.yedit = function(option)
	{
		var modal,
			theme = 'simple';
		areaedit = document.getElementById("edit");
		var seting = {
			basic:{
				"B":{
					"type":"a",
					"title":"加粗",
					"replaceStart":"**",
					"replaceEnd":"**",
					"click":null
				},
				"I":{
					"type":"a",
					"title":"强调",
					"replaceStart":"_",
					"replaceEnd":"_",
					"click":null
				},
				"Link":{
					"type":"a",
					"title":"链接",
					"click":addLink
				},
				"Code":{
					"type":"a",
					"title":"插入代码",
					"click":addCode
				},
				//"vt":{"type":"vertical"},
				"H3":{
					"type":"a",
					"title":"标题3",
					"replaceStart":"### ",
					"replaceEnd":" ###",
					"click":null
				},
				"H2":{
					"type":"a",
					"title":"标题2",
					"replaceStart":"## ",
					"replaceEnd":" ##",
					"click":null
				},
				"H1":{
					"type":"a",
					"title":"标题1",
					"replaceStart":"# ",
					"replaceEnd":" #",
					"click":null
				},
				"nlist":{
					"type":"a",
					"title":"无序列表",
					"id":"unlist",
					"replaceStart":"-",
					"content":" "
				},
				"ulist":{
					"type":"a",
					"title":"有序列表",
					"id":"numberlist",
					"replaceStart":"1.",
					"content":" "
				},
				"Imglink":{
					"type":"a",
					"title":"图片链接",
					"click":addImgLink
				},
				"upfile":{
					"type":"upload"
				}
			}
		};

		if(option.modal)
			modal = option.modal
		else
			modal = 'basic';

		//创建视图
		createView(this);
		function createView(tx)
		{
			var txf = $(tx).parent(),
				textarea = $(tx);
			var yeditDiv = $('<div id="edit-yedit"></div>');
			var yeditHeadDiv = $('<div id="edit-head-yedit"></div>');
			var yeditBodyerDiv = $('<div id="edit-bodyer-yedit"></div>');
			var yeditAlertDiv = $('<div class="alert alert-info upload-info"></div>');

			var yeditUl = $('<ul></ul>');
			for (k in seting[modal])
			{
				var button = seting[modal][k]['content']?seting[modal][k]['content']:k;
				var title = seting[modal][k]['title'];
				var type =  seting[modal][k]['type'];
				var yeditalink = $('<a title="'+title+'" href="javascript:void(0)">'+button+'</a>');
				yeditalink.attr("tag", k);

				if(type == "upload")
				{
					var yeditalink = $('<input type="file" id="file_upload"/>');
				}else if(type == "a"){

					if(seting[modal][k]['id'])
						yeditalink.attr("id", seting[modal][k]['id']);

					if(seting[modal][k]['click']){
						yeditalink.bind('click', seting[modal][k]['click']);
					}else{
						yeditalink.bind('click', function(){
							pos = cursorPosition.get(areaedit);
							var content = pos.text?pos.text:"内容";
							var start = seting[modal][$(this).attr("tag")]['replaceStart']?seting[modal][$(this).attr("tag")]['replaceStart']:"";
							var end = seting[modal][$(this).attr("tag")]['replaceEnd']?seting[modal][$(this).attr("tag")]['replaceEnd']:"";
							var result = start+""+content+""+end;
							cursorPosition.add(areaedit, pos, result);
						});
					}

				}else{
					var yeditalink = $('<span class="vertical">|</span>');
				}

				yeditUl.append($("<li></li>").html(yeditalink));
			}
			yeditHeadDiv.append(yeditUl);
			yeditBodyerDiv.append(textarea);
			yeditDiv.append(yeditHeadDiv).append(yeditBodyerDiv).append(yeditAlertDiv);

			txf.empty().html(yeditDiv);
			if(option.autoSave && $("input[name='autosave']").val()){
				interval = setInterval(asave, 60000);
				if($("input[name='id']").length == 0)
					yeditDiv.append('<input type="hidden" name="id" value="0"/>');
				txf.append('<div class="autosave"></div>');
			}
		}
	}
})(jQuery);

//添加链接
function addLink(){
	//$("#myLink").modal({backdrop:true});
	pos = cursorPosition.get(areaedit);
	var title = pos.text?pos.text:"标题";
	cursorPosition.add(areaedit, pos, "["+title+"](url)");
	$("#myLink").modal("hide");
}
//添加代码
function addCode(){
	//$("#myCode").modal({backdrop:true});
	pos = cursorPosition.get(areaedit);
	var cods = pos.text?pos.text:"代码";
	cursorPosition.add(areaedit, pos, "```java\n"+cods+"\n```");
	$("#myCode").modal("hide");
}
//添加图片链接
function addImgLink(){
	//$("#myImgLink").modal({backdrop:true});
	pos = cursorPosition.get(areaedit);
	cursorPosition.add(areaedit, pos, "![提示内容](url)");
	$("#myImgLink").modal("hide");
}

function asave(){
	var title   = $("input[name='title']").val(),
		content = $("textarea#edit").val(),
		id = $("input[name='id']").val();
		saveUrl = $("input[name='autosave']").val();
		if(id == 0 && (content.length == 0 || title.length == 0))
			return false;

		if(saveUrl){
			$.ajax({
				url:saveUrl,
				type:'POST',
				data:'title='+title+'&content='+encodeURIComponent(content)+'&id='+id,
				dataType:'json',
				success:function(data, textStatus){
					if(data.status == 1){
						if(data.data.update == 1){
							$("div.autosave").html("最后保存时间："+data.data['time']);
							$("input[name='id']").val(data.data.id);
						}
					}else{
						alert(data.info);
					}
				},
				error:function(){
					$("div.autosave").html("自动保存出错，请及时保存博客!");
					clearInterval(interval);
				}
			})
		}else{
			clearInterval(interval);
		}
}
