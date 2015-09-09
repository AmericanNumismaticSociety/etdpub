<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- url params -->
				<xsl:param name="q">pleiades_uri:*</xsl:param>
				<xsl:param name="sort">timestamp desc</xsl:param>
				<xsl:param name="start">0</xsl:param>
				<xsl:param name="rows" as="xs:integer">100000</xsl:param>
				<xsl:param name="fl">id,title,author,date,university,language,pleiades_uri,genre_uri,timestamp</xsl:param>
				
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr/url, 'select/')"/>
				
				<xsl:variable name="service">
					<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=', encode-for-uri($sort), '&amp;start=', $start, '&amp;rows=', $rows, '&amp;fl=', $fl)"/>
				</xsl:variable>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	
</p:config>
