<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	
	<!-- get the config and content XML files -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, 'etdpub/content.xml')"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="content-generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#content-generator-config"/>
		<p:output name="data" id="content"/>
	</p:processor>
	
	<!-- execute Solr search in order to create link for OAI-PMH and generic RDF export -->
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="solr-url" select="concat(/config/solr/url, 'select/')"/>				
				<xsl:variable name="service" select="concat($solr-url, '?q=*:*&amp;rows=0')"/>
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
		<p:output name="data" id="solr-oai-generator-config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#solr-oai-generator-config"/>
		<p:output name="data" id="solr-oai-response"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#solr-oai-response"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:template match="/">
					<response type="published">
						<xsl:value-of select="if(/response/result/@numFound &gt; 0) then 'true' else 'false'"/>
					</response>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="published"/>
	</p:processor>
	
	<!-- execute Solr search for Pleiades URIs to create link to Pelagios RDF export -->
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="solr-url" select="concat(/config/solr/url, 'select/')"/>				
				<xsl:variable name="service" select="concat($solr-url, '?q=pleiades_uri:*&amp;rows=0')"/>
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
		<p:output name="data" id="solr-pelagios-generator-config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#solr-pelagios-generator-config"/>
		<p:output name="data" id="solr-pelagios-response"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#solr-pelagios-response"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:template match="/">
					<response type="pelagios">
						<xsl:value-of select="if(/response/result/@numFound &gt; 0) then 'true' else 'false'"/>
					</response>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="pelagios"/>
	</p:processor>
	
	<!-- combine various XML models -->
	<p:processor name="oxf:identity">
		<p:input name="data" href="aggregate('index', #config, #content, #published, #pelagios)"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
