/**
 * Theme Plugins
 * @author ZhangHuihua@msn.com
 */
(function($){
	$.fn.extend({
		cssTable: function(options){
			var op = $.extend({scrollBox:"tableList"}, options);
			return this.each(function(){
				var $this = $(this);
				var $trs = $this.find('tbody>tr');
				if (!$this.parent().hasClass(op.scrollBox)){
					var lh = $this.attr('layoutH');
					$this.removeAttr('layoutH');
					$this.wrap('<div class="'+op.scrollBox+'"'+ (lh ? ' layoutH="'+lh+'"' : '') +'></div>');
				}
				var $grid = $this.parent(); // table scrollBox
				
				$trs.hover(function(){
					$(this).addClass('hover');
				}, function(){
					$(this).removeClass('hover');
				}).each(function(index){
					var $tr = $(this);
					if (index % 2 == 1) $tr.addClass("trbg");
					
					$tr.click(function(){
						$trs.filter(".selected").removeClass("selected");
						$tr.addClass("selected");
						var sTarget = $tr.attr("target");
						if (sTarget) {
							if ($("#"+sTarget, $grid).size() == 0) {
								$grid.prepend('<input id="'+sTarget+'" type="hidden" />');
							}
							$("#"+sTarget, $grid).val($tr.attr("rel"));
						}
					});
					
				});
				
			});
		}
	});
})(jQuery);
