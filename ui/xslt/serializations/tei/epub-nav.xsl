<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="tei xs xlink etdpub" version="2.0">

	<xsl:template match="//tei:TEI">
		<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<title>Table of Contents</title>
			</head>
			<body>
				<section class="frontmatter TableOfContents" epub:type="toc">
					<header>
						<h1>Table of Contents</h1>
					</header>
					<nav id="pub-toc" epub:type="toc">
						<ol class="toc">
							<xsl:apply-templates select="tei:text"/>
						</ol>
					</nav>
				</section>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="tei:text">
		<xsl:if test="descendant::tei:titlePage">
			<li>
				<a href="titlePage.xhtml">Title Page</a>
			</li>
		</xsl:if>
		<xsl:apply-templates select="descendant::tei:div1"/>
	</xsl:template>
	
	<xsl:template match="tei:div1">
		<xsl:variable name="marker" select="concat(parent::node()/local-name(), '-', format-number(position(), '000'))"/>
		
		<li>
			<a href="{$marker}.xhtml">
				<xsl:choose>
					<xsl:when test="tei:head">
						<xsl:value-of select="tei:head"/>
					</xsl:when>
					<xsl:otherwise>
						<i>[No title]</i>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			
			<xsl:if test="child::tei:div2">
				<ol>
					<xsl:apply-templates select="tei:div2">
						<xsl:with-param name="marker" select="$marker"/>
					</xsl:apply-templates>
					
				</ol>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="tei:div2">
		<xsl:param name="marker"/>
		
		<li>
			<a href="{$marker}.xhtml#{format-number(position(), '000')}">
				<xsl:choose>
					<xsl:when test="tei:head">
						<xsl:value-of select="tei:head"/>
					</xsl:when>
					<xsl:otherwise>
						<i>[No title]</i>
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>
