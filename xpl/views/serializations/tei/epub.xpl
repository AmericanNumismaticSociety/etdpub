<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2015 Ethan Gruber
	Function: Workflow chain to compile the necessary components for an EPUB file, serialize to /tmp, and package into a zip file with the Orbeon zip processor.
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

	<!-- ***** CONFIGS ***** -->
	<!-- serializer configs -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.zip')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat('file:///tmp/', $basename, '.xhtml')"/>
						</url>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="html-serializer-config"/>
	</p:processor>
	
	<!-- navigation HTML document -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.zip')"/>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat('file:///tmp/', $basename, '.nav.xhtml')"/>
						</url>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="nav-serializer-config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.zip')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat('file:///tmp/', $basename, '.opf')"/>
						</url>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="opf-serializer-config"/>
	</p:processor>

	<!-- zip config -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.zip')"/>

				<xsl:template match="/">
					<files file-name="{$basename}.epub">
						<file name="mimetype">file:///tmp/mimetype</file>
						<file name="META-INF/container.xml">file:///tmp/container.xml</file>
						<file name="OEBPS/index.xhtml">
							<xsl:value-of select="concat('file:///tmp/', $basename, '.xhtml')"/>
						</file>
						<file name="OEBPS/toc.xhtml">
							<xsl:value-of select="concat('file:///tmp/', $basename, '.nav.xhtml')"/>
						</file>
						<file name="OEBPS/content.opf">
							<xsl:value-of select="concat('file:///tmp/', $basename, '.opf')"/>
						</file>
					</files>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="zip-config"/>
	</p:processor>

	<!-- ***** WORKFLOW ***** -->
	<!-- 1. serialize the XML document into HTML to /tmp on the server -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="epub-html.xpl"/>
		<p:output name="data" id="html-content"/>
	</p:processor>

	<p:processor name="oxf:file-serializer">
		<p:input name="config" href="#html-serializer-config"/>
		<p:input name="data" href="#html-content"/>
	</p:processor>

	<!-- 2. generate and serialize container.xml -->
	<p:processor name="oxf:xml-converter">
		<p:input name="data">
			<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
				<rootfiles>
					<rootfile full-path="OEBPS/content.opf"
						media-type="application/oebps-package+xml"/>
				</rootfiles>
			</container>
		</p:input>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
				<encoding>utf-8</encoding>
				<version>1.0</version>
			</config>
		</p:input>
		<p:output name="data" id="container-xml"/>
	</p:processor>

	<p:processor name="oxf:file-serializer">
		<p:input name="config">
			<config>
				<url>file:///tmp/container.xml</url>
			</config>
		</p:input>
		<p:input name="data" href="#container-xml"/>
	</p:processor>
	
	<!-- 1. serialize the XML document into Navigation HTML -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="epub-nav.xpl"/>
		<p:output name="data" id="nav-content"/>
	</p:processor>
	
	<p:processor name="oxf:file-serializer">
		<p:input name="config" href="#nav-serializer-config"/>
		<p:input name="data" href="#nav-content"/>
	</p:processor>

	<!-- generate and serialize mimetype text file -->
	<p:processor name="oxf:text-converter">
		<p:input name="config">
			<config/>
		</p:input>
		<p:input name="data">
			<document>application/epub+zip</document>
		</p:input>
		<p:output name="data" id="mimetype"/>
	</p:processor>

	<p:processor name="oxf:file-serializer">
		<p:input name="config">
			<config>
				<url>file:///tmp/mimetype</url>
			</config>
		</p:input>
		<p:input name="data" href="#mimetype"/>
	</p:processor>

	<!-- generate and serialize content.opf -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="opf.xpl"/>
		<p:output name="data" id="content-opf"/>
	</p:processor>

	<p:processor name="oxf:file-serializer">
		<p:input name="config" href="#opf-serializer-config"/>
		<p:input name="data" href="#content-opf"/>
	</p:processor>

	<!-- for generating the zip config -->
	<p:processor name="oxf:zip">
		<p:input name="data" href="#zip-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>


</p:config>
