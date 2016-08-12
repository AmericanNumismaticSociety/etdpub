<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4">
				<xsl:template match="/">
					<xsl:variable name="id">
						<xsl:choose>
							<xsl:when test="contains(doc('input:request')/request/request-url, '/pdf')">
								<xsl:variable name="pieces" select="tokenize(doc('input:request')/request/request-url, '/')"/>
								<xsl:variable name="count" select="count($pieces)"/>
								
								<xsl:value-of select="$pieces[$count - 1]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="basename" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
								<xsl:choose>
									<xsl:when test="substring($basename, string-length($basename) - 3) = '.xml'">
										<xsl:value-of select="substring-before($basename, '.xml')"/>
									</xsl:when>
									<xsl:when test="substring($basename, string-length($basename) - 3) = '.rdf'">
										<xsl:value-of select="substring-before($basename, '.rdf')"/>
									</xsl:when>
									<xsl:when test="substring($basename, string-length($basename) - 4) = '.solr'">
										<xsl:value-of select="substring-before($basename, '.solr')"/>
									</xsl:when>
									<xsl:when test="substring($basename, string-length($basename) - 3) = '.opf'">
										<xsl:value-of select="substring-before($basename, '.opf')"/>
									</xsl:when>
									<xsl:when test="substring($basename, string-length($basename) - 3) = '.ncx'">
										<xsl:value-of select="substring-before($basename, '.ncx')"/>
									</xsl:when>
									<xsl:when test="substring($basename, string-length($basename) - 4) = '.epub'">
										<xsl:value-of select="substring-before($basename, '.epub')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$basename"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, 'etdpub/records/', $id, '.xml')"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>					
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>		
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
