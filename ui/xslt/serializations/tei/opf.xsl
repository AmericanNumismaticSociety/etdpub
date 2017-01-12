<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.idpf.org/2007/opf" version="2.0"
	exclude-result-prefixes="#all">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:template match="/">
		<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="pub-id" version="3.0" xml:lang="en">
			<metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/"
				xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
				<xsl:apply-templates select="/tei:TEI/tei:teiHeader"/>
			</metadata>
			<manifest>
				<item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml"/>
				<item href="toc.xhtml" id="toc" media-type="application/xhtml+xml" properties="nav"/>
				<xsl:if test="descendant::tei:titlePage">
					<item href="titlePage.xhtml" id="titlePage" media-type="application/xhtml+xml"/>
				</xsl:if>
				<!--<item href="index.xhtml" id="content" media-type="application/xhtml+xml"/>-->
				<xsl:for-each select="descendant::tei:div1">
					<item href="{parent::node()/local-name()}-{format-number(position(), '000')}.xhtml"
						id="{parent::node()/local-name()}-{format-number(position(), '000')}" media-type="application/xhtml+xml"/>
				</xsl:for-each>

				<!-- images files -->
				<xsl:for-each select="descendant::tei:graphic[@url]">
					<xsl:variable name="extension" select="tokenize(@url, '\.')[last()]"/>

					<item href="images/{@url}" id="img{position()}">
						<xsl:attribute name="media-type">
							<xsl:choose>
								<xsl:when test="matches(lower-case($extension), 'jpe?g')">image/jpeg</xsl:when>
								<xsl:when test="matches(lower-case($extension), 'png')">image/png</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</item>
				</xsl:for-each>

				<!-- css -->
				<item href="css/style.css" id="css" media-type="text/css"/>
			</manifest>
			<spine toc="ncx">
				<!--<itemref idref="content" linear="yes"/>-->
				<!--<itemref idref="header" linear="yes"/>-->
				<xsl:if test="descendant::tei:titlePage">
					<itemref idref="titlePage" linear="yes"/>
				</xsl:if>
				<xsl:for-each select="descendant::tei:div1">
					<itemref idref="{parent::node()/local-name()}-{format-number(position(), '000')}" linear="yes"/>
				</xsl:for-each>
				<itemref idref="toc" linear="no"/>
			</spine>
		</package>


	</xsl:template>

	<xsl:template match="tei:teiHeader">
		<xsl:apply-templates select="tei:fileDesc"/>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<dc:title>
			<xsl:value-of select="tei:titleStmt/tei:title"/>
		</dc:title>
		<xsl:apply-templates select="tei:titleStmt"/>
		<dc:identifier id="pub-id">
			<xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
		</dc:identifier>
		<dc:language>en</dc:language>
		<meta property="dcterms:modified">
			<xsl:value-of select="concat(substring-before(string(current-dateTime()), '.'), 'Z')"/>
		</meta>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<dc:title>
			<xsl:value-of select="tei:title"/>
		</dc:title>
		<xsl:for-each select="tei:author">
			<dc:creator>
				<xsl:value-of select="tei:name"/>
			</dc:creator>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
