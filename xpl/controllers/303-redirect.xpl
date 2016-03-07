<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				
				<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema" content-type="text/html">
						<![CDATA[<html>
							<head>
								<title>303 See Other</title>
							</head>
							<body>
								<h1>See Other</h1>
								<p>The answer to your request is located <a href="]]><xsl:value-of select="concat(/config/url, 'ark:/', /config/ark/naan, '/', $id)"/><![CDATA[">here</a>.</p>
							</body>
						</html>]]>					
					</xml>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="body"/>
	</p:processor>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<xsl:output indent="yes"/>
				
				<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
				<xsl:template match="/">
					<config>
						<status-code>303</status-code>
						<content-type>text/html</content-type>
						<header>
							<name>Location</name>
							<value>
								<xsl:value-of select="concat(/config/url, 'ark:/', /config/ark/naan, '/', $id)"/>
							</value>
						</header>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="header"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#body"/>
		<p:input name="config" href="#header"/>
	</p:processor>
</p:pipeline>
