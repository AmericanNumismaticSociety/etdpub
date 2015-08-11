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
				<!-- url params -->
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="sort">
					<xsl:choose>
						<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='sort']/value)">
							<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="contains(doc('input:request')/request/request-uri, '/feed/')">
								<xsl:text>timestamp desc</xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:param>
				<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
				<xsl:variable name="start_var" as="xs:integer">
					<xsl:choose>
						<xsl:when test="number($start)">
							<xsl:value-of select="$start"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:param name="rows" as="xs:integer">20</xsl:param>
				
				<!-- insert other params -->
				<xsl:variable name="other-params">
					<xsl:for-each select="doc('input:request')/request/parameters/parameter[not(name='start') and not(name='q') and not(name='sort') and not(name='rows')]">
						<xsl:value-of select="concat('&amp;', name, '=', encode-for-uri(value))"/>
					</xsl:for-each>
				</xsl:variable>
				
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr, 'select/')"/>
				
				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="string($q)">
							<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=', encode-for-uri($sort), '&amp;start=',$start_var, '&amp;rows=', $rows, '&amp;facet=true&amp;facet.field=geographic_facet&amp;facet.field=topic_facet&amp;facet.sort=index&amp;facet.limit=-1', $other-params)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($solr-url, '?q=*:*&amp;sort=', encode-for-uri($sort), '&amp;start=',$start_var, '&amp;rows=', $rows, '&amp;facet=true&amp;facet.field=geographic_facet&amp;facet.field=topic_facet&amp;facet.sort=index&amp;facet.limit=-1', $other-params)"/>
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
