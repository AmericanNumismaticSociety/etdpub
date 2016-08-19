<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- pipeline variable -->
				<xsl:variable name="pipeline" select="if (contains(doc('input:request')/request/request-uri, '/feed/')) then 'atom' else 'results'"/>
				
				
				<!-- url params -->
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="sort">
					<xsl:choose>
						<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='sort']/value)">
							<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$pipeline='atom'">
								<xsl:text>timestamp desc</xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:param>
				<xsl:param name="start" select="if (number(doc('input:request')/request/parameters/parameter[name='start']/value)) then doc('input:request')/request/parameters/parameter[name='start']/value else 0" as="xs:integer"/>
				<xsl:param name="rows"  select="if ($pipeline = 'atom') then 100 else /config/solr/rows" as="xs:integer"></xsl:param>
				
				<!-- insert other params -->
				<xsl:variable name="other-params">
					<xsl:for-each select="doc('input:request')/request/parameters/parameter[not(name='start') and not(name='q') and not(name='sort') and not(name='rows')]">
						<xsl:value-of select="concat('&amp;', name, '=', encode-for-uri(value))"/>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:variable name="fl">
					<xsl:choose>
						<xsl:when test="$pipeline='atom'">id,title,creator_facet,date,abstract,timestamp,media_url,media_type</xsl:when>
						<xsl:otherwise>id,title,author,editor,date,university,publisher_facet,series_facet,language,volume,issues,pages,volume_id,volume_title,thumbnail_image</xsl:otherwise>
					</xsl:choose>
					
				</xsl:variable>
				<xsl:variable name="facets" as="node()*">
					<facets>
						<!-- document metadata-->
						<facet>creator_facet</facet>
						<facet>genre_facet</facet>						
						<facet>publisher_facet</facet>
						<facet>series_facet</facet>						
						<!-- subjects -->
						<facet>field_of_numismatics_facet</facet>
						<facet>geographic_facet</facet>
						<facet>name_facet</facet>
						<facet>temporal_facet</facet>
						<facet>topic_facet</facet>
					</facets>
				</xsl:variable>
				
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr/url, 'select/')"/>
				
				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="string($q)">
							<xsl:choose>
								<xsl:when test="$pipeline='atom'">
									<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=', encode-for-uri($sort), '&amp;start=',$start, '&amp;rows=', $rows, '&amp;fl=', $fl, $other-params)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=', encode-for-uri($sort), '&amp;start=',$start, '&amp;rows=', $rows, '&amp;fl=', $fl, '&amp;hl=true&amp;hl.fl=text&amp;hl.snippets=3&amp;hl.simple.pre=%3Cstrong%3E&amp;hl.simple.post=%3C/strong%3E&amp;facet=true&amp;facet.field=', string-join($facets//facet, '&amp;facet.field='), '&amp;facet.sort=index&amp;facet.limit=-1', $other-params)"/>
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$pipeline='atom'">
									<xsl:value-of select="concat($solr-url, '?q=*:*&amp;sort=', encode-for-uri($sort), '&amp;start=',$start, '&amp;rows=', $rows, '&amp;fl=', $fl, $other-params)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($solr-url, '?q=*:*&amp;sort=', encode-for-uri($sort), '&amp;start=',$start, '&amp;rows=', $rows, '&amp;fl=', $fl, '&amp;hl=true&amp;hl.fl=text&amp;hl.snippets=3&amp;hl.simple.pre=%3Cstrong%3E&amp;hl.simple.post=%3C/strong%3E&amp;facet=true&amp;facet.field=', string-join($facets//facet, '&amp;facet.field='), '&amp;facet.sort=index&amp;facet.limit=-1', $other-params)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
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
