<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="tei xs xlink etdpub" version="2.0">
	<xsl:include href="xhtml-templates.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/tei:TEI/@xml:id"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/tei:TEI"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<title>
					<xsl:value-of select="//tei:titleStmt/tei:title"/>
				</title>
				<!--<link rel="shortcut icon" type="image/x-icon"
					href="{$display_path}ui/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-\- bootstrap -\->
				<link rel="stylesheet"
					href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/{//config/style}.css"/>-->
			</head>
			<body>
				<xsl:call-template name="display"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<xsl:apply-templates select="tei:teiHeader"/>
		
		<xsl:apply-templates select="tei:text/tei:body"/>
		
		<!-- endnotes -->
		<xsl:if test="count(tei:text/descendant::tei:note[@place]) &gt; 0">
			<section epub:type="footnotes" id="endnotes">
				<h2>End Notes</h2>
				<ul>
					<xsl:apply-templates select="tei:text/descendant::tei:note[@place]"
						mode="endnote"/>
				</ul>
			</section>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:teiHeader">
		<h2 itemprop="name">
			<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title"/>
		</h2>
		<h4 itemprop="author">
			<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:author"/>
		</h4>
	</xsl:template>

	<!-- structural elements -->
	<xsl:template match="tei:body">				
		<!-- call other content -->
		<xsl:apply-templates select="tei:div1"/>
	</xsl:template>	

	<!-- *** TEMPLATES *** -->
	<!-- table of contents -->
</xsl:stylesheet>
