<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:variable name="display_path">./</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="/index/config/title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}/ui/images/favicon.png"/>
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
						<xsl:value-of select="/index/config/title"/>
					</h1>
					<div class="col-sm-12 col-md-6 col-md-offset-3">
						<xsl:call-template name="search"/>
					</div>
					<div class="col-sm-12 col-md-8 col-md-offset-2">
						<xsl:copy-of select="/index/content/index"/>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="search">
		<form action="{$display_path}results" class="search-form info-window" method="get">
			<input type="text" name="q" class="form-control" placeholder="Keyword Search"/>
			<button id="keyword_button" class="btn btn-primary">
				<span class="glyphicon glyphicon-search"/>
			</button>
		</form>
	</xsl:template>
</xsl:stylesheet>
