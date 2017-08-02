<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.crossref.org/schema/4.4.0" version="2.0" exclude-result-prefixes="#all">


	<!-- URI variables -->
	<xsl:variable name="id" select="/tei:TEI/@xml:id"/>
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="doc('input:config-xml')/config/ark/@enabled = 'true'">
				<xsl:value-of select="concat(doc('input:config-xml')/config/url, 'ark:/', doc('input:config-xml')/config/ark/naan, '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(doc('input:config-xml')/config/url, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	

	<xsl:template match="/tei:TEI">
		<doi_batch version="4.4.0" xmlns="http://www.crossref.org/schema/4.4.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.crossref.org/schema/4.4.0
			http://www.crossref.org/schemas/crossref4.4.0.xsd">
			<head>
				<doi_batch_id/>
				<timestamp/>
				<depositor>
					<depositor_name/>
					<email_address/>
				</depositor>
				<registrant/>
			</head>
			<body>
				<!-- evaluate whether it is a book of chapters or some other type of book -->
				<xsl:choose>
					<xsl:when
						test="descendant::*[starts-with(local-name(), 'div')][@type = 'chapter']/tei:byline/descendant-or-self::*[(local-name() = 'name' and @type = 'pname') or local-name() = 'persName']"> </xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:teiHeader">
							<xsl:with-param name="type">monograph</xsl:with-param>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</body>
		</doi_batch>
	</xsl:template>

	<xsl:template match="tei:teiHeader">
		<xsl:param name="type"/>

		<book book_type="{$type}">
			<xsl:apply-templates select="tei:fileDesc"/>
		</book>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<book_metadata language="en">
			<xsl:apply-templates select="tei:titleStmt | tei:publicationStmt"/>
			<doi_data>
				<doi><xsl:value-of select="concat(doc('input:config-xml')/config/crossref/doi_prefix, '/', $id)"/></doi>
				<resource><xsl:value-of select="concat($uri_space, $id)"/></resource>
			</doi_data>
		</book_metadata>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<publication_date>
			<year>
				<xsl:choose>
					<xsl:when test="tei:date castable as xs:gYear">
						<xsl:value-of select="tei:date"/>
					</xsl:when>
					<xsl:when test="matches(tei:date, '1|2[0-9]{3}')">
						<xsl:value-of select="normalize-space(substring-after(tei:date, ','))"/>
					</xsl:when>
					<xsl:otherwise>
						
					</xsl:otherwise>
				</xsl:choose>
			</year>
		</publication_date>
		<publisher>
			<publisher_name>
				<xsl:value-of select="tei:publisher/tei:name"/>
			</publisher_name>
		</publisher>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<titles>
			<title>
				<xsl:value-of select="tei:title"/>
			</title>
			<xsl:if test="tei:subtitle">
				<subtitle>
					<xsl:value-of select="tei:subtitle"/>
				</subtitle>
			</xsl:if>
		</titles>
	</xsl:template>
</xsl:stylesheet>
