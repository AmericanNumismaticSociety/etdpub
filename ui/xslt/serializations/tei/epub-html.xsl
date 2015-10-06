<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub"
	xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="tei xs xlink etdpub" version="2.0">
	<!-- xml method must be explicitly forced, or else the meta element does not conform to EPUB validation (defaults to xhtml) -->
	<xsl:output encoding="UTF-8" indent="yes"/>
	<xsl:include href="xhtml-templates.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/tei:TEI"/>
		
		
	</xsl:template>
	
	<xsl:template match="tei:TEI">
		<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<title>
					<xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
				</title>
				<link rel="stylesheet" href="css/style.css"/>
			</head>
			<body>		
				<xsl:apply-templates select="tei:text"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="tei:text">
		<xsl:apply-templates select="tei:body/tei:div1"/>
	</xsl:template>
	
	<xsl:template match="tei:div1">
		<section epub:type="{@type}">
			<xsl:variable name="frag"
				select="concat(parent::node()/local-name(), '-', format-number(count(preceding-sibling::tei:div1) + 1, '000'))"/>
			
			<a id="{$frag}"/>
			
			<xsl:apply-templates select="*"/>
		</section>
		<xsl:if test="count(descendant::tei:note[@place]) &gt; 0">
			<section epub:type="rearnotes">
				<h2>End Notes</h2>
				<ul>
					<xsl:apply-templates select="descendant::tei:note[@place]"
						mode="endnote"/>
				</ul>
			</section>						
		</xsl:if>
	</xsl:template>

	<!--<xsl:template match="tei:div1">
		<xsl:result-document
			href="file:///tmp/{$id}-{parent::node()/local-name()}-{format-number(position(), '000')}.xhtml">		
			<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
				<head>
					<title>
						<xsl:value-of select="tei:head"/>
					</title>
					<xsl:element name="meta">
						<xsl:attribute name="http-equiv">content-type</xsl:attribute>
						<xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
					</xsl:element>
					<link rel="stylesheet" href="css/style.css"/>
				</head>
				<body>
					<section epub:type="{@type}">
						<xsl:apply-templates select="*"/>
					</section>
					<xsl:if test="count(descendant::tei:note[@place]) &gt; 0">
						<section epub:type="rearnotes">
							<h2>End Notes</h2>
							<ul>
								<xsl:apply-templates select="descendant::tei:note[@place]"
									mode="endnote"/>
							</ul>
						</section>						
					</xsl:if>
				</body>
			</html>
		</xsl:result-document>

	</xsl:template>-->


	<!--<xsl:template match="tei:teiHeader">
		<xsl:result-document href="file:///tmp/{$id}-teiHeader.xhtml">
			<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
				<head>
					<title>
						<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title"/>
					</title>
					<meta http-equiv="content-type" content="text/html; charset=utf-8" />
					<link rel="stylesheet" href="css/style.css"/>
				</head>
				<body>
					<section epub:type="titlepage">
						<div>
							<h2>
								<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title"/>
							</h2>
							<h4>
								<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:author"/>
							</h4>
						</div>
					</section>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>-->
</xsl:stylesheet>
