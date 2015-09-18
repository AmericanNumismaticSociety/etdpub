<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="tei xs xlink etdpub" version="2.0">

	<xsl:template match="/">
		<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<title>Table of Contents</title>
			</head>
			<body>
				<xsl:apply-templates select="descendant::tei:body"/>
			</body>
		</html>
	</xsl:template>
	
	<!-- table of contents -->
	<xsl:template match="tei:body">
		<section class="frontmatter TableOfContents" epub:type="toc">
			<header>
				<h1>Table of Contents</h1>
			</header>
			<nav id="pub-toc" epub:type="toc">
				<ol class="toc">
					<xsl:apply-templates select="tei:div1" mode="toc"/>
				</ol>
			</nav>
		</section>
		
	</xsl:template>
	
	<xsl:template match="tei:div1|tei:div2" mode="toc">
		
		<xsl:variable name="frag">
			<xsl:choose>
				<xsl:when test="@xml:id">
					<xsl:value-of select="@xml:id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="local-name()='div1'">
							<xsl:value-of select="concat(@type, format-number(position(), '000'))"/>
						</xsl:when>
						<xsl:when test="local-name()='div2'">
							<xsl:value-of select="concat(parent::node()/@type, format-number(count(../preceding-sibling::node()[local-name()='div1']) + 1, '000'), '_', @type, format-number(position(), '000'))"/>
						</xsl:when>
					</xsl:choose>					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<li>
			<a href="index.xhtml#{$frag}">
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
					<xsl:apply-templates select="tei:div2" mode="toc"/>
					
				</ol>
			</xsl:if>
		</li>
	</xsl:template>
</xsl:stylesheet>
