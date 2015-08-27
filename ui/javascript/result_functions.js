$(document).ready(function () {
	$('#keyword_button').click(function () {
		var query = new Array();
		var text = $('#search_text').val();
		
		if (text.length > 0) {
			query.push(getQuery());
			query.push(text);
		}
		
		$(this).siblings('input[name=q]').attr('value', query.join(' AND '));
	});
});

/*******************
FUNCTIONS USED IN FACET-BASED PAGES: BROWSE, COLLECTION, AND MAPS
 ********************/

//assemble query
function getQuery() {
	//get categories
	query = new Array();
	
	//get non-facet fields that may have been passed from search
	var query_terms = $('#facet_form_query').attr('value').split(' AND ');
	var non_facet_terms = new Array();
	for (i in query_terms) {
		if (query_terms[i].indexOf('_facet') < 0 && query_terms[i] != '*:*') {
			non_facet_terms.push(query_terms[i]);
		}
	}
	if (non_facet_terms.length > 0) {
		query.push(non_facet_terms.join(' AND '));
	}
	
	//get multiselects
	$('select.multiselect').each(function () {
		var val = $(this).val();
		var facet = $(this).attr('id').split('-')[0];
		if (val != null) {
			segments = new Array();
			for (var i = 0; i < val.length; i++) {
				segments.push(facet + ':"' + val[i] + '"');
			}
			if (segments.length > 1) {
				query.push('(' + segments.join(' OR ') + ')');
			} else {
				query.push(segments[0]);
			}
		}
	});
	
	//set the value attribute of the q param to the query assembled by javascript
	if (query.length > 0) {
		return query.join(' AND ');
	} else {
		return '*:*';
	}
}