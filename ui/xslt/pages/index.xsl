<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:variable name="display_path">./</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="/config/title"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container content">
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="/config/title"/>
					</h1>
					<div>
						<!--<xsl:call-template name="search"/>-->
					</div>
					<p>Information</p>
				</div>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name="search">
		<form action="{$display_path}results" class="filter-form" method="get">
			<span>
				<b>Keyword: </b>
			</span>
			<input type="text" id="search_text" class="form-control" placeholder="Search"/>
			<input type="hidden" name="q"/>
			<input type="hidden" id="facet_form_query"/>
			<button id="keyword_button" class="btn btn-default">
				<span class="glyphicon glyphicon-search"/>
			</button>
		</form>
	</xsl:template>
</xsl:stylesheet>
