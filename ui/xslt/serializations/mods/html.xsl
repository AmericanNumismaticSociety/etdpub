<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>


	<xsl:variable name="display_path">
		<xsl:text>../</xsl:text>
	</xsl:variable>

	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:variable name="id" select="//mods:recordIdentifier"/>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="bio">http://purl.org/vocab/bio/0.1/</namespace>
			<namespace prefix="dcterms">http://purl.org/dc/terms/</namespace>
			<namespace prefix="foaf">http://xmlns.com/foaf/0.1/</namespace>
			<namespace prefix="geo">http://www.w3.org/2003/01/geo/wgs84_pos#</namespace>
			<namespace prefix="org">http://www.w3.org/ns/org#</namespace>
			<namespace prefix="owl">http://www.w3.org/2002/07/owl#</namespace>
			<namespace prefix="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</namespace>
			<namespace prefix="skos">http://www.w3.org/2004/02/skos/core#</namespace>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/mods:modsCollection/mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<html lang="en">
			<!-- dynamically generate prefix attribute -->
			<xsl:attribute name="prefix">
				<xsl:for-each select="$namespaces//namespace">
					<xsl:value-of select="@prefix"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:attribute>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$url}ui/css/style.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container-fluid" typeof="" about="{$id}">
			<div class="row">
				<div class="col-md-12">
					<h1><xsl:value-of select="mods:titleInfo/mods:title"/></h1>
					<dl class="dl-horizontal">
						<dt>Author</dt>
						<dd><xsl:value-of select="mods:name/mods:namePart"/></dd>
						<dt>Date</dt>
						<dd><xsl:value-of select="mods:originInfo/mods:dateCreated"/></dd>
					</dl>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
