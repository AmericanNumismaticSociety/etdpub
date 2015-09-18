<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.idpf.org/2007/opf" version="2.0" exclude-result-prefixes="#all">
	<xsl:template match="/">
		<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="pub-id" version="3.0"
			xml:lang="en">
			<metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/"
				xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata"
				xmlns:dc="http://purl.org/dc/elements/1.1/">
				<xsl:apply-templates select="/tei:TEI/tei:teiHeader"/>
			</metadata>
			<manifest>
				<item href="index.xhtml" id="content" media-type="application/xhtml+xml"/>
				<item href="toc.xhtml" id="toc" media-type="application/xhtml+xml" properties="nav"/>
			</manifest>
			<spine>
				<itemref idref="toc" linear="no"/>
				<itemref idref="content" linear="yes"/>
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
		<dc:identifier id="pub-id">
			<xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
		</dc:identifier>
		<dc:language>en</dc:language>
		<meta property="dcterms:modified">
			<xsl:value-of select="concat(substring-before(string(current-dateTime()), '.'), 'Z')"/>
		</meta>
	</xsl:template>
</xsl:stylesheet>
