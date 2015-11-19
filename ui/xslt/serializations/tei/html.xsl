<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="html-templates.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>

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
					<xsl:value-of select="//tei:titleStmt/tei:title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon"
					href="{$display_path}ui/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet"
					href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/{//config/style}.css"/>
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
					<!-- title and bibliographic metadata -->
					<xsl:apply-templates select="tei:teiHeader"/>

					<xsl:apply-templates select="tei:text/tei:body"/>

					<!-- endnotes -->
					<xsl:if test="count(tei:text/descendant::tei:note[@place]) &gt; 0">
						<h2>End Notes</h2>
						<ul>
							<xsl:apply-templates select="tei:text/descendant::tei:note[@place]"
								mode="endnote"/>
						</ul>
					</xsl:if>
				</div>
			</div>
		</div>
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
		<!-- table of contents -->
		<xsl:call-template name="toc"/>

		<!-- call other content -->
		<xsl:apply-templates/>
	</xsl:template>	

	<!-- *** TEMPLATES *** -->
	<!-- table of contents -->
	<xsl:template name="toc">
		<xsl:if test="count(tei:div1) &gt; 1">
			<section epub:type="toc">
			<h2>Table of Contents <small><a href="#" id="toggle-toc"><span
				class="glyphicon glyphicon-triangle-right"/></a></small></h2>
				<nav id="pub-toc" style="display:none">
					<ul class="toc">
						<xsl:apply-templates select="tei:div1" mode="toc"/>
					</ul>
				</nav>
			</section>
		</xsl:if>

	</xsl:template>

	
</xsl:stylesheet>
