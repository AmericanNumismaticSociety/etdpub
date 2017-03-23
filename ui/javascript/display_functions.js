$(document).ready(function () {
	$('a.thumbImage').fancybox({
		helpers: {
			title: {
				type: 'inside'
			}
		}
	});
	
	$('a.note-button').fancybox({
	     beforeShow: function () {
            var id = this.element.attr('note');
            $('#' + id).clone().appendTo('#note-container table');
         },
         afterClose: function(){
             //clear table on close
             $('#note-container').children('table').html('');
         }
	});
	
	//toggle symbol div
	$('.toggle-btn').click(function () {
		var section = $(this).attr('id').split('-')[1];
		if ($(this).children('span').hasClass('glyphicon-triangle-bottom')) {
			$(this).children('span').removeClass('glyphicon-triangle-bottom');
			$(this).children('span').addClass('glyphicon-triangle-right');
		} else {
			$(this).children('span').removeClass('glyphicon-triangle-right');
			$(this).children('span').addClass('glyphicon-triangle-bottom');
		}
		$('#section-' + section).toggle('fast');
		return false;
	});
});