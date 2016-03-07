<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				
				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema" content-type="text/html">
<![CDATA[<html>
	<head>
		<title>ARK URI Error</title>
	</head>
	<body>
		<h1>ARK URI Error</h1>
		<p>Mismatch between NAAN in the URI and in the EADitor config or ARK URIs have not been enabled. Return <a href="]]><xsl:value-of select="/config/url"/><![CDATA[">home</a>.</p>
	</body>
</html>]]>
					</xml>
					
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="error-body"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#error-body"/>
		<p:input name="config" >
			<config>
				<status-code>400</status-code>
				<content-type>text/html</content-type>
			</config>
		</p:input>
	</p:processor>
</p:pipeline>
