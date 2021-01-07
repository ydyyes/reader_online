function initEnv() {
	if ( $.browser.msie && /6.0/.test(navigator.userAgent) ) {
		try {
			document.execCommand("BackgroundImageCache", false, 1);	
		}catch(e){	
		}
	}
	initLayout();
	$(window).resize(function(){
		initLayout();
		$(this).trigger("resizeGrid");
	});

	$("#leftside").jBar({minW:150, maxW:700});
	
	if ($.taskBar) $.taskBar.init();
	if (navTab) navTab.init();
	$("#switchEnvBox").switchEnv();
	initUI();

	$("#taskbar li").hoverClass("hover");
	$("#taskbar li.selected").hoverClass("selectedHover");
	$("#taskbar .close").hoverClass("closeHover");
	$("#taskbar .restore").hoverClass("restoreHover");
	$("#taskbar .minimize").hoverClass("minimizeHover");
	$("#taskbar .taskbarLeft").hoverClass("taskbarLeftHover");
	$("#taskbar .taskbarRight").hoverClass("taskbarRightHover");
	
	// tab styles
	var jTabsPH = $("div.tabsPageHeader");
	jTabsPH.find(".tabsLeft").hoverClass("tabsLeftHover");
	jTabsPH.find(".tabsRight").hoverClass("tabsRightHover");
	jTabsPH.find(".tabsMore").hoverClass("tabsMoreHover");

	setTimeout(function(){
		var ajaxbg = $("#background,#progressBar");
		ajaxbg.hide();
		$(document).ajaxStart(function(){
			ajaxbg.show();
		}).ajaxStop(function(){
			ajaxbg.hide();
		});
	}, 500);
}
function initLayout(){
	var iContentW = $(window).width() - (DWZ.ui.sbar ? $("#sidebar").width() + 10 : 34) - 5;
	var iContentH = $(window).height() - $("#header").height() - 34;

	$("#container").width(iContentW);
	$("#container .tabsPageContent").height(iContentH - 34).find("[layoutH]").layoutH();
	$("#sidebar, #sidebar_s .collapse, #splitBar, #splitBarProxy").height(iContentH - 5);
	$("#taskbar").css({top: iContentH + $("#header").height() + 5, width:$(window).width()});
}

function initUI(_box){
	var jParent = $(_box || document);

	//tables
	$("table.table", jParent).jTable();
	
	// css tables
	$('table.list').cssTable();

	//auto bind tabs
	$("div.tabs", jParent).each(function(){
		var $this = $(this);
		var options = {};
		options.currentIndex = $this.attr("currentIndex") || 0;
		options.eventType = $this.attr("eventType") || "click";
		$this.tabs(options);
	});

	$("ul.tree", jParent).jTree();
	$('div.accordion', jParent).each(function(){
		var $this = $(this);
		$this.accordion({fillSpace:$this.attr("fillSpace"),alwaysOpen:true,active:0});
	});

	$(":button.checkboxCtrl, :checkbox.checkboxCtrl").checkboxCtrl(jParent);
	
	$("select.combox",jParent).combox();
	
	if ($.fn.xheditor) {
		$("textarea.editor", jParent).each(function(){
			var $this = $(this);
			$this.xheditor({skin: 'vista',tools: $this.attr("tools") || 'full'});
		});
	}
	if ($.fn.uploadify) {
		$(":file[uploader]", jParent).each(function(){
			var $this = $(this);
			var options = {
				uploader: $this.attr("uploader"),
				script: $this.attr("script"),
				cancelImg: $this.attr("cancelImg"),
				queueID: $this.attr("fileQueue") || "fileQueue",
				fileDesc: "*.jpg;*.jpeg;*.gif;*.png;*.pdf",
				fileExt : "*.jpg;*.jpeg;*.gif;*.png;*.pdf",
				folder	: $this.attr("folder"),
				auto: true,
				multi: true,
				onError:uploadifyError,
				onComplete: uploadifyComplete,
				onAllComplete: uploadifyAllComplete
			};
			if ($this.attr("onComplete")) {
				options.onComplete = DWZ.jsonEval($this.attr("onComplete"));
			}
			if ($this.attr("onAllComplete")) {
				options.onAllComplete = DWZ.jsonEval($this.attr("onAllComplete"));
			}
			if ($this.attr("scriptData")) {
				options.scriptData = DWZ.jsonEval($this.attr("scriptData"));
			}
			$this.uploadify(options);
		});
	}
	
	// init styles
	$("input[type=text], input[type=password], textarea", jParent).addClass("textInput").focusClass("focus");

	$("input[readonly], textarea[readonly]", jParent).addClass("readonly");
	$("input[disabled=true], textarea[disabled=true]", jParent).addClass("disabled");

	$("input[type=text]", jParent).not("div.tabs input[type=text]", jParent).filter("[alt]").inputAlert();

	//Grid ToolBar
	$("div.panelBar li, div.panelBar", jParent).hoverClass("hover");

	//Button
	$("div.button", jParent).hoverClass("buttonHover");
	$("div.buttonActive", jParent).hoverClass("buttonActiveHover");
	
	//tabsPageHeader
	$("div.tabsHeader li, div.tabsPageHeader li, div.accordionHeader, div.accordion", jParent).hoverClass("hover");
	
	$("div.panel", jParent).jPanel();

	//validate form
	$("form.required-validate", jParent).each(function(){
		$(this).validate({
			focusInvalid: false,
			focusCleanup: true,
			errorElement: "span",
			ignore:".ignore",
			invalidHandler: function(form, validator) {
				var errors = validator.numberOfInvalids();
				if (errors) {
					var message = DWZ.msg("validateFormError",[errors]);
					alertMsg.error(message);
				} 
			}
		});
	});

	if ($.fn.datepicker){
		$('input.date', jParent).each(function(){
			var $this = $(this);
			var opts = {};
			if ($this.attr("pattern")) opts.pattern = $this.attr("pattern");
			if ($this.attr("yearstart")) opts.yearstart = $this.attr("yearstart");
			if ($this.attr("yearend")) opts.yearend = $this.attr("yearend");
			$this.datepicker(opts);
		});
	}

	// navTab
	$("a[target=navTab]", jParent).each(function(){
		$(this).click(function(event){
			var $this = $(this);
			var title = $this.attr("title") || $this.text();
			var tabid = $this.attr("rel") || "_blank";
			var flesh = eval($this.attr("flesh") || "true");
			var url = unescape($this.attr("href")).replaceTmById(jParent);
			DWZ.debug(url);
			if (!url.isFinishedTm()) {
				alertMsg.error($this.attr("warn") || DWZ.msg("alertSelectMsg"));
				return false;
			}
			navTab.openTab(tabid, url,{title:title, flesh:flesh});

			event.preventDefault();
		});
	});
	// navTabTodo
	$("a[target=navTabTodo]", jParent).each(function(){
		$(this).click(function(event){
			var $this = $(this);
			var url = unescape($this.attr("href")).replaceTmById(jParent);
			DWZ.debug(url);
			if (!url.isFinishedTm()) {
				alertMsg.error($this.attr("warn") || DWZ.msg("alertSelectMsg"));
				return false;
			}
			var title = $this.attr("title");
			if (title) {
				alertMsg.confirm(title, {
					okCall: function(){
						navTabTodo(url, $this.attr("callback"));
					}
				});
			} else {
				navTabTodo(url, $this.attr("callback"));
			}
			event.preventDefault();
		});
	});
	
	//dialogs
	$("a[target=dialog]", jParent).each(function(){
		$(this).click(function(event){
			var $this = $(this);
			var title = $this.attr("title") || $this.text();
			var rel = $this.attr("rel") || "_blank";
			var options = {};
			var w = $this.attr("width");
			var h = $this.attr("height");
			if (w) options.width = w;
			if (h) options.height = h;
			options.max = eval($this.attr("max") || "false");
			options.mask = eval($this.attr("mask") || "false");
			options.maxable = eval($this.attr("maxable") || "true");
			options.minable = eval($this.attr("minable") || "true");
			options.flesh = eval($this.attr("flesh") || "true");
			options.resizable = eval($this.attr("resizable") || "true");
			options.drawable = eval($this.attr("drawable") || "true");
			options.close = eval($this.attr("close") || "");
			options.param = $this.attr("param") || "";
			
			var url = unescape($this.attr("href")).replaceTmById(jParent);
			DWZ.debug(url);
			if (!url.isFinishedTm()) {
				alertMsg.error($this.attr("warn") || DWZ.msg("alertSelectMsg"));
				return false;
			}
			$.pdialog.open(url, rel, title, options);
			
			return false;
		});
	});
	$("a[target=ajax]", jParent).each(function(){
		$(this).click(function(event){
			var $this = $(this);
			var rel = $this.attr("rel");
			if (rel) $("#"+rel).loadUrl($this.attr("href"));

			event.preventDefault();
		});
	});
	
	$("div.pagination", jParent).each(function(){
		var $this = $(this);
		$this.pagination({
			targetType:$this.attr("targetType"),
			totalCount:$this.attr("totalCount"),
			numPerPage:$this.attr("numPerPage"),
			pageNumShown:$this.attr("pageNumShown"),
			currentPage:$this.attr("currentPage")
		});
	});

}

function closedialog(param) {
	alert(param.msg);
	return true;
}

