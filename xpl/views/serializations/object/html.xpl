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
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- handle ARK URIs or the standard id/ URI Space -->
	<p:choose href="#request">
		<!-- when the URI matches ark:/ -->
		<p:when test="contains(//request-url, 'ark:/')">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<xsl:variable name="naan" select="substring-before(substring-after(doc('input:request')/request/request-url, 'ark:/'), '/')"/>
						
						<xsl:template match="/">
							<xsl:choose>
								<xsl:when test="/config/ark/@enabled = 'true' and /config/ark/naan = $naan">
									<naan-valid>true</naan-valid>
								</xsl:when>
								<xsl:otherwise>
									<naan-valid>false</naan-valid>
								</xsl:otherwise>						
							</xsl:choose>
						</xsl:template>						
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="naan-valid"/>
			</p:processor>
			
			<p:choose href="#naan-valid">
				<!-- if the NAAN in the URI matches the NAAN in the config and ARK is enabled, then serialize into HTML -->
				<p:when test="/naan-valid = 'true'">
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
				</p:when>
				<!-- otherwise, display an HTTP 400 bad request -->
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../../controllers/400-bad-request.xpl"/>		
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<!-- otherwise evaluate conditionals in id/ URI space -->
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">				
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						
						<xsl:template match="/">
							<xsl:choose>
								<xsl:when test="/config/ark/@enabled = 'true'">
									<ark-enabled>true</ark-enabled>
								</xsl:when>
								<xsl:otherwise>
									<ark-enabled>false</ark-enabled>
								</xsl:otherwise>						
							</xsl:choose>
						</xsl:template>						
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="ark-enabled"/>
			</p:processor>
			
			<p:choose href="#ark-enabled">
				<!-- if the  ARK is enabled, then set up 303 See Other redirect -->
				<p:when test="/ark-enabled = 'true'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../../controllers/303-redirect.xpl"/>		
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<!-- otherwise execute transformation -->
				<p:otherwise>
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
				</p:otherwise>
			</p:choose>			
		</p:otherwise>
	</p:choose>
</p:config>