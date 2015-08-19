<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- request params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="rows" select="/content/config/solr/rows" as="xs:integer"/>
	<xsl:param name="start" select="if (number(doc('input:request')/request/parameters/parameter[name='start']/value)) then doc('input:request')/request/parameters/parameter[name='start']/value else
		0" as="xs:integer"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>

	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- language normalization -->
	<xsl:variable name="languages" as="node()*">
		<xsl:copy-of select="document('oxf:/apps/etdpub/xforms/instances/languages.xml')/*"/>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>

				<!-- multiselect -->
				<script type="text/javascript" src="{$display_path}ui/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/bootstrap-multiselect.css" type="text/css"/>

				<script type="text/javascript" src="{$display_path}ui/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>

				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>

				<!-- variables -->
				<div class="hidden">
					<span id="path">
						<xsl:value-of select="$display_path"/>
					</span>
					<select id="ajax-temp" style="display:none"/>
				</div>
			</body>
		</html>

	</xsl:template>

	<xsl:template name="body">
		<div class="container">
			<div class="row">
				<div class="col-md-9">
					<xsl:choose>
						<xsl:when test="$numFound &gt; 0">
							<h1>Browse</h1>
							<xsl:call-template name="search"/>
							<xsl:if test="string($q) and $q != '*:*'">
								<xsl:call-template name="remove_facets"/>
							</xsl:if>
							<xsl:call-template name="paging"/>
							<xsl:apply-templates select="descendant::doc"/>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<p>No results found for this query. <a href="{$display_path}">Clear search</a>.</p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="col-md-3">
					<h3>Subjects</h3>
					<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="id" select="str[@name='id']"/>

		<div class="result-doc row">
			<h4>
				<a href="id/{$id}">
					<xsl:value-of select="str[@name='title']"/>
				</a>
			</h4>

			<!-- hit highlighting -->
			<xsl:choose>
				<xsl:when test="//lst[@name='highlighting']/lst[@name=$id]/arr[@name='text']/str">
					<div class="col-md-6">
						<xsl:call-template name="metadata"/>
					</div>
					<div class="col-md-6">
						<xsl:variable name="snippets" select="saxon:parse(concat('&lt;div&gt;', string-join(//lst[@name='highlighting']/lst[@name=$id]/arr[@name='text']/str, '...'), '&lt;/div&gt;'))"/>

						<div class="highlight">
							<xsl:copy-of select="$snippets"/>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="metadata"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="lst[@name='facet_fields']">
		<xsl:for-each select="lst[descendant::int]">
			<xsl:variable name="val" select="@name"/>
			<xsl:variable name="new_query">
				<xsl:for-each select="$tokenized_q[not(contains(., $val))]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> AND </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="title">
				<xsl:value-of select="etdpub:normalize_fields(@name)"/>
			</xsl:variable>
			<xsl:variable name="select_new_query">
				<xsl:choose>
					<xsl:when test="string($new_query)">
						<xsl:value-of select="$new_query"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>*:*</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<select id="{@name}-select" title="{$title}" q="{$q}" new_query="{if (contains($q, @name)) then $select_new_query else ''}" class="multiselect" multiple="multiple">
				<xsl:if test="contains($q, @name)">
					<xsl:copy-of select="document(concat($url, 'get_facets/?q=', encode-for-uri($q), '&amp;category=', @name, '&amp;sort=index&amp;limit=-1'))//option"/>
				</xsl:if>
			</select>
		</xsl:for-each>
		<form action="." id="facet_form">
			<input type="hidden" name="q" id="facet_form_query" value="{if (string($q)) then $q else '*:*'}"/>
			<br/>
			<div class="submit_div">
				<input type="submit" value="Refine Search" id="search_button" class="btn btn-default"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template name="metadata">
		<dl class="dl-horizontal">
			<dt>Author</dt>
			<dd>
				<xsl:value-of select="str[@name='author']"/>
			</dd>
			<dt>Date</dt>
			<dd>
				<xsl:value-of select="str[@name='date']"/>
			</dd>
			<dt>University</dt>
			<dd>
				<xsl:value-of select="str[@name='university']"/>
			</dd>
			<xsl:for-each select="arr[@name='language']/str">
				<xsl:variable name="lang" select="."/>
				<dt>Language</dt>
				<dd>
					<xsl:value-of select="$languages/language[@value=$lang]"/>
				</dd>
			</xsl:for-each>
			<!--<dt>Abstract</dt>
				<dd>
					<xsl:value-of select="str[@name='abstract']"/>
				</dd>-->
		</dl>
	</xsl:template>

	<xsl:template name="search">
		<form action="{$display_path}results" class="filter-form" method="get">
			<span>
				<b>Keyword: </b>
			</span>
			<input type="text" id="search_text" class="form-control" placeholder="Search">
				<xsl:if test="count($tokenized_q[contains(., 'text:')]) &gt; 0">
					<xsl:attribute name="value" select="replace(string-join($tokenized_q[contains(., 'text:')], ' '), 'text:', '')"/>
				</xsl:if>
			</input>
			<input type="hidden" name="q"/>
			<button id="keyword_button" class="btn btn-default">
				<span class="glyphicon glyphicon-search"/>
			</button>
		</form>
	</xsl:template>

	<xsl:template name="remove_facets">
		<div class="col-md-12 filter-container">
			<h3>Filters</h3>
			<xsl:for-each select="$tokenized_q">
				<xsl:variable name="val" select="."/>
				<xsl:variable name="new_query">
					<xsl:for-each select="$tokenized_q[not($val = .)]">
						<xsl:value-of select="."/>
						<xsl:if test="position() != last()">
							<xsl:text> AND </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				
				<!--<xsl:value-of select="."/>-->
				<xsl:choose>
					<xsl:when test="not(. = '*:*') and not(substring(., 1, 1) = '(')">
						<xsl:variable name="field" select="substring-before(., ':')"/>
						<xsl:variable name="name">
							<xsl:choose>
								<xsl:when test="string($field)">
									<xsl:value-of select="etdpub:normalize_fields($field)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="etdpub:normalize_fields($field)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="term">
							<xsl:choose>
								<xsl:when test="string(substring-before(., ':'))">
									<xsl:value-of select="replace(substring-after(., ':'), '&#x022;', '')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="replace(., '&#x022;', '')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<div class="stacked_term row">
							<!-- establish orientation based on language parameter -->
							<div class="col-md-10">
								<span>
									<b><xsl:value-of select="$name"/>: </b>
									<xsl:choose>
										<xsl:when test="$field='century_num'">
											<!--<xsl:value-of select="numishare:normalize_century($term)"/>-->
										</xsl:when>
										<xsl:when test="contains($field, '_hier')">
											<xsl:variable name="tokens" select="tokenize(substring($term, 2, string-length($term)-2), '\+')"/>
											<xsl:for-each select="$tokens[position() &gt; 1]">
												<xsl:sort/>
												<xsl:value-of select="normalize-space(substring-after(., '|'))"/>
												<xsl:if test="not(position()=last())">
													<xsl:text>--</xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$term"/>
										</xsl:otherwise>
									</xsl:choose>
								</span>
							</div>
							<div class="col-md-2 text-right">
								<a href="{$display_path}results?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else
									''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</div>
						
					</xsl:when>
					<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
					<xsl:when test="substring(., 1, 1) = '('">
						<xsl:variable name="tokenized-fragments" select="tokenize(., ' OR ')"/>
						
						<div class="stacked_term row">
							<div class="col-md-10">
								<span>
									<xsl:for-each select="$tokenized-fragments">
										<xsl:variable name="field" select="substring-before(translate(., '()', ''), ':')"/>
										<xsl:variable name="after-colon" select="substring-after(., ':')"/>
										
										<xsl:variable name="value">
											<xsl:choose>
												<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
													<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
														<xsl:matching-substring>
															<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:when>
												<xsl:when test="substring($after-colon, 1, 1) = '('">
													<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
														<xsl:matching-substring>
															<xsl:value-of select="concat('(', regex-group(1), ')')"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:when>
												<xsl:otherwise>
													<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
														<xsl:matching-substring>
															<xsl:value-of select="regex-group(1)"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										
										<xsl:variable name="q_string" select="concat($field, ':', $value)"/>
										
										<!--<xsl:variable name="value" select="."/>-->
										<xsl:variable name="new_multicategory">
											<xsl:for-each select="$tokenized-fragments[not(contains(.,$q_string))]">
												<xsl:variable name="other_field" select="substring-before(translate(., '()', ''), ':')"/>
												<xsl:variable name="after-colon" select="substring-after(., ':')"/>
												
												<xsl:variable name="other_value">
													<xsl:choose>
														<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
															<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
																<xsl:matching-substring>
																	<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:when>
														<xsl:when test="substring($after-colon, 1, 1) = '('">
															<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
																<xsl:matching-substring>
																	<xsl:value-of select="concat('(', regex-group(1), ')')"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:when>
														<xsl:otherwise>
															<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
																<xsl:matching-substring>
																	<xsl:value-of select="regex-group(1)"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<xsl:value-of select="concat($other_field, ':', encode-for-uri($other_value))"/>
												<xsl:if test="position() != last()">
													<xsl:text> OR </xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:variable>
										<xsl:variable name="multicategory_query">
											<xsl:choose>
												<xsl:when test="contains($new_multicategory, ' OR ')">
													<xsl:value-of select="concat('(', $new_multicategory, ')')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$new_multicategory"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										
										
										<b>
											<xsl:value-of select="etdpub:normalize_fields($field)"/>
											<xsl:text>: </xsl:text>
										</b>
										
										<xsl:choose>
											<xsl:when test="$field='century_num'">
												<!--<xsl:value-of select="numishare:normalize_century($value)"/>-->
											</xsl:when>
											<xsl:when test="contains($field, '_hier')">
												<xsl:variable name="tokens" select="tokenize(substring($value, 2, string-length($value)-2), '\+')"/>
												<xsl:for-each select="$tokens[position() &gt; 1]">
													<xsl:sort/>
													<xsl:value-of select="normalize-space(replace(substring-after(., '|'), '&#x022;', ''))"/>
													<xsl:if test="not(position()=last())">
														<xsl:text>--</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$value"/>
											</xsl:otherwise>
										</xsl:choose>
										
										<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
										<a href="{$display_path}results?q={if (string($multicategory_query) and string($new_query)) then concat($new_query, ' AND ', $multicategory_query) else if
											(string($multicategory_query) and not(string($new_query))) then $multicategory_query else $new_query}{if (string($lang)) then concat('&amp;lang=',
											$lang)            else ''}">
											<span class="glyphicon glyphicon-remove"/>
										</a>
										
										<xsl:if test="position() != last()">
											<xsl:text> OR </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</span>
							</div>
							<div class="col-md-2 text-right">
								<a href="{$display_path}results?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else
									''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="not(contains(., ':'))">
						<div class="stacked_term row">
							<div class="col-md-12">
								<span>
									<b>Keyword: </b>
									<xsl:value-of select="."/>
								</span>
							</div>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			
			<!-- remove sort term -->
			<xsl:if test="string($sort)">
				<xsl:variable name="field" select="substring-before($sort, ' ')"/>
				<xsl:variable name="name">
					<xsl:value-of select="etdpub:normalize_fields($field)"/>
				</xsl:variable>
				
				<xsl:variable name="order">
					<xsl:choose>
						<xsl:when test="substring-after($sort, ' ') = 'asc'">Acending</xsl:when>
						<xsl:when test="substring-after($sort, ' ') = 'desc'">Descending</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="stacked_term row">
					<div class="col-md-10">
						<span>
							<b>Sort Category: </b>
							<xsl:value-of select="$name"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$order"/>
						</span>
					</div>
					<div class="col-md-2">
						<a href="{$display_path}results?q={$q}">
							<span class="glyphicon glyphicon-remove"/>
						</a>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="count($tokenized_q) &gt; 2">
				<div class="stacked_term row">
					<div class="col-md-12">
						<a id="clear_all" href="{$display_path}results"><span class="glyphicon glyphicon-remove"/>Clear All Terms</a>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start &gt;= $rows">
					<xsl:value-of select="$start - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div row">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$start + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start + $rows)">
							<xsl:value-of select="$start + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<span>
					<b>
						<xsl:value-of select="$startRecord"/>
					</b>
					<xsl:text> to </xsl:text>
					<b>
						<xsl:value-of select="$endRecord"/>
					</b>
					<text> of </text>
					<b>
						<xsl:value-of select="$numFound"/>
					</b>
					<xsl:text> total results.</xsl:text>
				</span>
			</div>



			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group" style="float:right">
						<xsl:choose>
							<xsl:when test="$start &gt;= $rows">
								<a class="btn btn-default" title="First" href="browse?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default" title="Previous" href="browse?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="First" href="browse?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default disabled" title="Previous" href="browse?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else
									''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
						<!-- current page -->
						<button type="button" class="btn btn-default disabled">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<!-- next page -->
						<xsl:choose>
							<xsl:when test="$numFound - $start &gt; $rows">
								<a class="btn btn-default" title="Next" href="results?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" href="results?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next" href="results?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled" href="results?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else
									''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
