<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<!-- read request header for content-type -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/*">
					<namespace>
						<xsl:choose>
							<xsl:when test="namespace-uri()='http://www.loc.gov/mods/v3'">mods</xsl:when>
							<xsl:when test="namespace-uri()='http://www.tei-c.org/ns/1.0'">tei</xsl:when>
						</xsl:choose>
					</namespace>					
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="namespace-config"/>
	</p:processor>
	
	<p:choose href="#namespace-config">
		<p:when test="namespace='mods'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../mods/html.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="namespace='tei'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../tei/html.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
	</p:choose>
</p:config>