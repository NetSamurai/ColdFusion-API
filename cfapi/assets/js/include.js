function loadDefault() {
	$.ajaxSetup({ cache: false });
	 
	$( "button" ).button();
	// add button styling
	$('.addButton').button( "option", "icons", { primary: "ui-icon-circle-plus" } );
	// back button styling
	$('.backButton').button( "option", "icons", { primary: "ui-icon-circle-triangle-w" } );
	// play button styling
	$('.playButton').button( "option", "icons", { primary: "ui-icon-play" } );
	// script button styling
	$('.scriptButton').button( "option", "icons", { primary: "ui-icon-script" } );
	// gear button styling
	$('.gearButton').button( "option", "icons", { primary: "ui-icon-gear" } );
	// wrench button styling
	$('.wrenchButton').button( "option", "icons", { primary: "ui-icon-wrench" } );
	
	$("button, input[type='button'], input[type='submit']").button()
		.bind('mouseup', function() {
			$(this).blur();     // prevent jquery ui button from remaining in the active state
	});

	$( ".datePicker" ).datepicker({
		maxDate: "+10y",
		minDate: "-100y",
		buttonText: "Select a date",
		showOn: "button",
		buttonImage: "assets/img/calendar.png",
		buttonImageOnly: true,
		showButtonPanel: true,
		closeText: 'Cancel'
	});

	$( ".checkboxradio" ).checkboxradio({
		icon: false
	});

	$( ".multiselectable" ).selectable({
		selected: function( event, ui ) {
			multiselectableHandler(event, ui);
		}
	});

	$('input:radio').each(function() {
		var $element = $(this);
		var element_id = $element.prop('id').toString().trim();
		var element_name = $element.prop('name').toString().trim();
		var element_checked = $element.prop('checked').toString().trim();
		var $element_label = $("label[for='" + element_id + "']");
		if(element_checked === "true") {
			$element_label.addClass("ui-visual-focus");
		}
		
		$element.change(function() {
			element_name = $element.prop('name').toString().trim();
			element_checked = $element.prop('checked').toString().trim();
			element_id = $element.prop('id').toString().trim();
			$element_label = $("label[for='" + element_id + "']");

			if(element_checked === "true") {
				$element_label.addClass("ui-visual-focus");
			} else {
				$element_label.removeClass("ui-visual-focus");
			}
			
			$('.radio_label').each(function() {
				$element_label = $(this);
				element_id = $element_label.prop('htmlFor').toString().trim();
				$element = $('#' + element_id);
				element_checked = $element.prop('checked').toString().trim();
				
				if(element_checked === "false") {
					$element_label.removeClass("ui-visual-focus");
				} else if(element_checked === "true") {
					$element_label.addClass("ui-visual-focus");
				}
			});
		});
	});
	
	$(".hideOnLoad").css("visibility","visible");
}

function cleanCssHighlight(scope, new_row) {
	$('#' + scope + '_div span').each(function(){
		var $element = $(this);
		var element_id = $element.prop('id').toString().trim();
		if(element_id.search('container') === -1) {
			$(this).removeClass("headerSimple");
			$(this).addClass("color-one");
		}
	});
	$('#' + scope + '_' + new_row + '_span').removeClass("color-one");
	$('#' + scope + '_' + new_row + '_span').addClass("headerSimple");
}

function copyToClipboard(element_id) {
	if (document.selection) { 
		var range = document.body.createTextRange();
		range.moveToElementText(document.getElementById(element_id));
		range.select().createTextRange();
		document.execCommand("copy"); 
	
	} else if (window.getSelection) {
		var range = document.createRange();
		 range.selectNode(document.getElementById(element_id));
		 window.getSelection().addRange(range);
		 document.execCommand("copy");
	}

	$(this).blur();
}

$.getScript('/assets/js/jquery.ui.window.framework.min.js', function(){});