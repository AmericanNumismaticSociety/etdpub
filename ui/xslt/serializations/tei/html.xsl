<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/tei:TEI/@xml:id"/>

	<xsl:variable name="namespaces" as="node()*">
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
		<xsl:apply-templates select="/content/tei:TEI"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
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
					<!--<xsl:value-of select="mods:titleInfo/mods:title"/>-->
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}ui/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$url}ui/css/{//config/style}.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container content" itemtype="http://schema.org/Book">
			<div class="row">
				<div class="col-md-12">
					<h2 itemprop="name">
						test
						<!--<xsl:value-of select="mods:titleInfo/mods:title"/>-->
					</h2>
				</div>
				<div class="col-md-12">
					<!--<dl class="dl-horizontal">
						<xsl:for-each select="mods:name">
							<dt>Author</dt>
							<dd itemprop="author">
								<xsl:value-of select="mods:namePart"/>
							</dd>
						</xsl:for-each>						
						<dt>Date</dt>
						<dd itemprop="dateCreated">
							<xsl:value-of select="mods:originInfo/mods:dateCreated"/>
						</dd>
						<dt>Publisher</dt>
						<dd itemprop="publisher">
							<xsl:value-of select="mods:originInfo/mods:publisher"/>
						</dd>
						<xsl:for-each select="mods:language">
							<xsl:variable name="lang" select="mods:languageTerm"/>

							<dt>Language</dt>
							<dd>
								<xsl:value-of select="$languages/language[@value=$lang]"/>
							</dd>
						</xsl:for-each>
						<dt>Abstract</dt>
						<dd itemprop="about">
							<xsl:value-of select="mods:abstract"/>
						</dd>
					</dl>-->
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
