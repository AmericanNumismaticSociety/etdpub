$(document).ready(function () {
	//toggle symbol div
	$('.toggle-btn').click(function(){
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