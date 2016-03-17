$(document).ready(function () {
	$('a.thumbImage').fancybox({
		beforeShow: function () {
			this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
		},
		helpers: {
			title: {
				type: 'inside'
			}
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