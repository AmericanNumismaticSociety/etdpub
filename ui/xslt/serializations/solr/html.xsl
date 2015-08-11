<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<!-- request params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="rows">100</xsl:param>
	<xsl:param name="sort">
		<xsl:if test="string(doc('input:request')/request/parameters/parameter[name='sort']/value)">
			<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
		</xsl:if>
	</xsl:param>
	<xsl:param name="start">
		<xsl:choose>
			<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="display_path"/>

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
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>

	</xsl:template>

	<xsl:template match="doc">
		<div class="result-doc">
			<h4>
				<a href="id/{str[@name='id']}">
					<xsl:value-of select="str[@name='title']"/>
				</a>				
			</h4>
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
				<dt>Abstract</dt>
				<dd>
					<xsl:value-of select="str[@name='abstract']"/>
				</dd>
			</dl>
		</div>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid">
			<div class="row">				
				<div class="col-md-9">
					<xsl:choose>
						<xsl:when test="$numFound &gt; 0">
							<xsl:call-template name="paging"/>
							<xsl:apply-templates select="descendant::doc"/>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<p>No results found for this query. <a href="../browse">Clear search</a>.</p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="col-md-3"> sidebar </div>
			</div>
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
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div row">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
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
							<xsl:when test="$start_var &gt;= $rows">
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
							<xsl:when test="$numFound - $start_var &gt; $rows">
								<a class="btn btn-default" title="Next" href="browse?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" href="browse?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next" href="browse?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled" href="browse?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else
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
