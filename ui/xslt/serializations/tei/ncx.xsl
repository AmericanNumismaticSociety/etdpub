<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" version="2.0" exclude-result-prefixes="#all">
	<xsl:template match="/">
		<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="en">
			<head>
				<meta content="awp{current-dateTime()}Z" name="dtb:uid"/>
				<meta content="{if (descendant::tei:div2) then '2' else '1'}" name="dtb:depth"/>
				<meta content="0" name="dtb:totalPageCount"/>
				<meta content="0" name="dtb:maxPageNumber"/>
			</head>
			<docTitle>
				<text>
					<xsl:value-of
						select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
				</text>
			</docTitle>
			<navMap>
				<xsl:for-each select="descendant::tei:body/tei:div1">
					<xsl:variable name="marker"
						select="concat(parent::node()/local-name(), '-', format-number(position(), '000'))"/>

					<navPoint id="{$marker}"
						playOrder="{count(preceding-sibling::tei:div1) + count(preceding-sibling::tei:div1/tei:div2) + 1}">
						<navLabel>
							<text>
								<xsl:choose>
									<xsl:when test="tei:head">
										<xsl:value-of select="tei:head"/>
									</xsl:when>
									<xsl:otherwise>
										<i>[No title]</i>
									</xsl:otherwise>
								</xsl:choose>
							</text>
						</navLabel>
						<content src="{$marker}.xhtml"/>
						<xsl:for-each select="tei:div2">
							<navPoint id="{$marker}-{format-number(position(), '000')}"
								playOrder="{count(preceding-sibling::tei:div2) + count(../preceding-sibling::tei:div1) + count(../preceding-sibling::tei:div1/tei:div2) + 2}">
								<navLabel>
									<text>
										<xsl:choose>
											<xsl:when test="tei:head">
												<xsl:value-of select="tei:head"/>
											</xsl:when>
											<xsl:otherwise>
												<i>[No title]</i>
											</xsl:otherwise>
										</xsl:choose>
									</text>
								</navLabel>
								<content src="{$marker}.xhtml#{format-number(position(), '000')}"/>
							</navPoint>
						</xsl:for-each>
					</navPoint>
				</xsl:for-each>
			</navMap>
		</ncx>

	</xsl:template>
</xsl:stylesheet>
