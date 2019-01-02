<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2015 Ethan Gruber
	Function: Workflow chain to compile the necessary components for an EPUB file, serialize to /tmp, and package into a zip file with the Orbeon zip processor.
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:tei="http://www.tei-c.org/ns/1.0">

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
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.epub')"/>

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
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.epub')"/>

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
	
	<!-- NCX -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.epub')"/>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat('file:///tmp/', $basename, '.ncx')"/>
						</url>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="ncx-serializer-config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.epub')"/>

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

	<!-- generate directory scanner config -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(/request/request-url, '/')[last()], '.epub')"/>

				<xsl:template match="/">
					<config>
						<base-directory>
							<!--<xsl:value-of select="concat('oxf:/apps/etdpub/media/reference/', $basename)"/>-->
							<xsl:value-of select="concat('file:///usr/local/projects/etdpub/media/', $basename, '/reference')"/>
						</base-directory>
						<include>*.jpg</include>
						<include>*.png</include>
						<include>*.gif</include>
						<case-sensitive>true</case-sensitive>
						<default-excludes>true</default-excludes>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="directory-scanner-config"/>
	</p:processor>

	<p:processor name="oxf:directory-scanner">
		<p:input name="config" href="#directory-scanner-config"/>
		<p:output name="data" id="directory-scan"/>
	</p:processor>

	<!-- zip config -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="request" href="#request"/>
		<p:input name="scan" href="#directory-scan"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="basename"
					select="substring-before(tokenize(doc('input:request')/request/request-url, '/')[last()], '.epub')"/>
				<xsl:variable name="path" select="doc('input:scan')/directory/@path"/>

				<xsl:template match="/">
					<files file-name="{$basename}.epub">
						<file name="mimetype">file:///tmp/mimetype</file>
						<file name="META-INF/container.xml">file:///tmp/container.xml</file>
						<!--<file name="OEBPS/teiHeader.xhtml">
							<xsl:value-of select="concat('file:///tmp/', $basename, '-teiHeader.xhtml')"/>
						</file>-->
						<xsl:if test="descendant::tei:titlePage">
							<file name="OEBPS/titlePage.xhtml">
								<xsl:value-of select="concat('file:///tmp/', $basename, '-titlePage.xhtml')"/>
							</file>
						</xsl:if>
						<!-- generate chapters -->
						<xsl:for-each select="descendant::tei:div1">
							<file name="OEBPS/{parent::node()/local-name()}-{format-number(position(), '000')}.xhtml">
								<xsl:value-of select="concat('file:///tmp/', $basename, '-', parent::node()/local-name(), '-', format-number(position(), '000'), '.xhtml')"/>
							</file>
						</xsl:for-each>						
						<file name="OEBPS/toc.xhtml">
							<xsl:value-of select="concat('file:///tmp/', $basename, '.nav.xhtml')"/>
						</file>
						<file name="OEBPS/toc.ncx">
							<xsl:value-of select="concat('file:///tmp/', $basename, '.ncx')"/>
						</file>
						<file name="OEBPS/content.opf">
							<xsl:value-of select="concat('file:///tmp/', $basename, '.opf')"/>
						</file>
						<!-- CSS -->
						<!--<file name="OEBPS/css/style.css">oxf:/apps/etdpub/ui/css/epub.css</file>-->
						<file name="OEBPS/css/style.css">oxf:/apps/etdpub/ui/css/epub.css</file>
						<!-- directory-scan to include images -->
						<xsl:for-each select="doc('input:scan')//file">
							<file name="OEBPS/images/{@name}">
								<xsl:value-of select="concat('file://', $path, '/', @name)"/>
							</file>
						</xsl:for-each>
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

	<!-- this will generate a dummy record to force the result-document for individual chapters -->
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
	
	<!-- serialize into Nav HTML -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="epub-nav.xpl"/>
		<p:output name="data" id="nav-content"/>
	</p:processor>
	
	<p:processor name="oxf:file-serializer">
		<p:input name="config" href="#nav-serializer-config"/>
		<p:input name="data" href="#nav-content"/>
	</p:processor>


	<!-- 3. serialize the XML document into NCX -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="ncx.xpl"/>
		<p:output name="data" id="ncx-content"/>
	</p:processor>

	<p:processor name="oxf:file-serializer">
		<p:input name="config" href="#ncx-serializer-config"/>
		<p:input name="data" href="#ncx-content"/>
	</p:processor>

	<!-- 4. generate and serialize mimetype text file -->
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

	<!-- 5. generate and serialize content.opf -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="opf.xpl"/>
		<p:output name="data" id="content-opf"/>
	</p:processor>

	<p:processor name="oxf:file-serializer">
		<p:input name="config" href="#opf-serializer-config"/>
		<p:input name="data" href="#content-opf"/>
	</p:processor>

	<!-- 6. generate zip file -->
	<p:processor name="oxf:zip">
		<p:input name="data" href="#zip-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
