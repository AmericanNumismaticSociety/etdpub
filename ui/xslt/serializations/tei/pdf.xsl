<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="#all" version="2.0">

	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="/content/config/ark/@enabled='true'">
				<xsl:value-of select="concat(/content/config/url, 'ark:/', /content/config/ark/naan, '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(/content/config/url, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>

	<xsl:template match="/">
		<xsl:apply-templates select="//tei:TEI"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<fo:root xsl:use-attribute-sets="doc-font">
			<fo:layout-master-set>
				<fo:simple-page-master xsl:use-attribute-sets="layout" master-name="metadata">
					<fo:region-body region-name="xsl-region-body"/>
				</fo:simple-page-master>
				<xsl:if test="count(descendant::tei:div1) &gt; 0">
					<fo:simple-page-master xsl:use-attribute-sets="layout" master-name="toc">
						<fo:region-body region-name="xsl-region-body"/>
					</fo:simple-page-master>
				</xsl:if>
				<fo:simple-page-master xsl:use-attribute-sets="layout" master-name="frontmatter">
					<fo:region-body region-name="xsl-region-body" margin-bottom=".5in"/>
					<fo:region-after region-name="footer"/>
				</fo:simple-page-master>
				<fo:simple-page-master xsl:use-attribute-sets="layout" master-name="content">
					<fo:region-body region-name="xsl-region-body" margin-bottom=".5in"/>
					<fo:region-after region-name="footer"/>
				</fo:simple-page-master>
			</fo:layout-master-set>

			<!-- metadata -->
			<fo:declarations>
				<x:xmpmeta xmlns:x="adobe:ns:meta/" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
					<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<rdf:Description rdf:about="{concat($uri_space, $id)}" xmlns:dc="http://purl.org/dc/elements/1.1/">
							<!-- Dublin Core properties go here -->
							<dc:title>
								<xsl:value-of select="//tei:titleStmt/tei:title"/>
							</dc:title>
							<dc:publisher>
								<xsl:value-of select="//tei:publicationStmt/tei:publisher/tei:name"/>
							</dc:publisher>
							<xsl:for-each select="//tei:titleStmt/tei:author">
								<dc:creator>
									<xsl:value-of select="tei:name"/>
								</dc:creator>
							</xsl:for-each>
							<xsl:for-each select="//tei:titleStmt/tei:editor">
								<dc:contributor>
									<xsl:value-of select="tei:name"/>
								</dc:contributor>
							</xsl:for-each>
							<xmp:CreationDate>
								<xsl:value-of select="current-dateTime()"/>
							</xmp:CreationDate>
						</rdf:Description>
					</rdf:RDF>
				</x:xmpmeta>
			</fo:declarations>

			<!-- pages -->
			<fo:page-sequence master-reference="metadata">
				<fo:title>Metadata</fo:title>
				<fo:flow flow-name="xsl-region-body">
					<!-- teiHeader generated title page -->
					<xsl:apply-templates select="tei:teiHeader"/>
				</fo:flow>
			</fo:page-sequence>
			<xsl:if test="count(descendant::tei:div1) &gt; 0">
				<fo:page-sequence master-reference="toc" initial-page-number="1">
					<fo:title>Table of Contents</fo:title>
					<fo:flow flow-name="xsl-region-body">
						<xsl:call-template name="toc"/>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			<fo:page-sequence master-reference="frontmatter" format="i" initial-page-number="1">
				<fo:title>Frontmatter</fo:title>
				<fo:static-content flow-name="footer">
					<fo:block xsl:use-attribute-sets="smaller" text-align="center">
						<fo:page-number/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:apply-templates select="tei:text/tei:front"/>
				</fo:flow>
			</fo:page-sequence>
			<fo:page-sequence master-reference="content" initial-page-number="1">
				<fo:title>
					<xsl:value-of select="//tei:titleStmt/tei:title"/>
				</fo:title>
				<fo:static-content flow-name="footer">
					<fo:block xsl:use-attribute-sets="smaller" text-align="center">
						<fo:page-number/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:apply-templates select="tei:text/tei:body|tei:text/tei:back"/>
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>

	<xsl:template match="tei:front|tei:body|tei:back">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[starts-with(local-name(), 'div')]">
		<fo:block id="{generate-id()}">
			<xsl:choose>
				<xsl:when test="self::tei:div1">
					<xsl:attribute name="page-break-after">always</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="margin-top">2em</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="(parent::tei:front and following::tei:titlePage) or self::tei:titlePage">
					<xsl:attribute name="text-align">center</xsl:attribute>
					<xsl:attribute name="margin-top">33%</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="text-align">justify</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="*[not(local-name()='note')]"/>
		</fo:block>
	</xsl:template>

	<!-- suppress cover -->
	<xsl:template match="tei:div1[@type='cover']"/>

	<xsl:template match="tei:head">
		<xsl:variable name="size">
			<xsl:choose>
				<xsl:when test="starts-with(parent::node()/local-name(), 'div')">
					<xsl:variable name="level" select="number(substring-after(parent::node()/local-name(), 'div'))"/>
					<xsl:value-of select="etdpub:font-size($level)"/>
				</xsl:when>
				<xsl:when test="parent::tei:figure">
					<xsl:variable name="level" select="number(substring(ancestor::*[starts-with(local-name(), 'div')][1]/local-name(), 4, 1))"/>
					<xsl:value-of select="etdpub:font-size($level)"/>
				</xsl:when>
				<xsl:otherwise>16</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<fo:block font-size="{$size}px" font-weight="bold">
			<xsl:if test="parent::tei:div1">
				<xsl:attribute name="text-align">center</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:byline">
		<fo:block text-align="center" xsl:use-attribute-sets="p">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:p">
		<fo:block xsl:use-attribute-sets="p">
			<xsl:apply-templates select="node()|@rend"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:hi[not(parent::tei:head)]">
		<fo:inline>
			<xsl:apply-templates select="node()|@*"/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="tei:lb">
		<fo:block/>
	</xsl:template>
	
	<!-- bibliography -->
	<xsl:template match="tei:listBibl">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:listBibl/tei:bibl">
		<fo:block xsl:use-attribute-sets="bibref">
			<xsl:choose>
				<xsl:when test="tei:idno[@type='URI']">
					<fo:basic-link external-destination="{tei:idno[@type='URI']}" xsl:use-attribute-sets="hyperlink">
						<xsl:apply-templates select="node()[not(tei:idno[@type='URI'])]"/>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<!--  quotes -->
	<xsl:template match="tei:quote">
		<fo:block xsl:use-attribute-sets="blockquote">
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
			<xsl:apply-templates select="tei:figure"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:q">
		<fo:inline>
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
		</fo:inline>
		<xsl:apply-templates select="tei:figure"/>
	</xsl:template>

	<!-- address -->
	<xsl:template match="tei:address">
		<fo:block xsl:use-attribute-sets="p">
			<xsl:for-each select="tei:addrLine">
				<xsl:value-of select="."/>
				<fo:block/>
			</xsl:for-each>
		</fo:block>
	</xsl:template>

	<!-- tables and lists-->
	<xsl:template match="tei:table">
		<xsl:choose>
			<xsl:when test="tei:head">
				<fo:table-and-caption xsl:use-attribute-sets="p">
					<fo:table-caption>
						<xsl:apply-templates select="tei:head"/>
					</fo:table-caption>
					<fo:table>
						<fo:table-body>
							<xsl:apply-templates select="tei:row"/>
						</fo:table-body>
					</fo:table>
				</fo:table-and-caption>
			</xsl:when>
			<xsl:otherwise>
				<fo:table xsl:use-attribute-sets="p" table-layout="">
					<fo:table-body>
						<xsl:apply-templates select="tei:row"/>
					</fo:table-body>
				</fo:table>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:row">
		<fo:table-row>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="tei:cell">
		<fo:table-cell>
			<fo:block>
				<xsl:apply-templates select="node()|@rend"/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<xsl:template match="tei:list">
		<fo:list-block xsl:use-attribute-sets="p">
			<xsl:apply-templates/>
		</fo:list-block>
	</xsl:template>

	<xsl:template match="tei:item">
		<fo:list-item space-after="0.5ex">
			<fo:list-item-label start-indent="2em">
				<fo:block>
					<xsl:choose>
						<xsl:when test="@n">
							<xsl:value-of select="@n"/>
						</xsl:when>
						<xsl:otherwise>•</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="3em">
				<fo:block>
					<!-- ignore @rend on the item -->
					<xsl:apply-templates/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<!-- linking elements -->
	<xsl:template match="tei:name[@corresp]">
		<xsl:variable name="nameId" select="substring-after(@corresp, '#')"/>
		<xsl:variable name="entity" as="element()*">
			<xsl:copy-of select="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc//*[starts-with(local-name(), 'list')]/*[@xml:id=$nameId]"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$entity//tei:idno[@type='URI']">
				<fo:basic-link external-destination="url({$entity//tei:idno[@type='URI']})" xsl:use-attribute-sets="hyperlink">
					<xsl:value-of select="."/>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:ref">
		<xsl:choose>
			<xsl:when test="contains(@target, '#')">
				<xsl:variable name="noteId" select="substring-after(@target, '#')"/>

				<xsl:apply-templates select="//tei:note[@xml:id=$noteId]" mode="footnote">
					<xsl:with-param name="val" select="."/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<fo:basic-link xsl:use-attribute-sets="hyperlink">
					<xsl:attribute name="external-destination">
						<xsl:value-of select="concat('url(', @target, ')')"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</fo:basic-link>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- footnote -->
	<xsl:template match="tei:note" mode="footnote">
		<xsl:param name="val"/>

		<fo:footnote margin-left="2em">
			<fo:inline xsl:use-attribute-sets="footnote">
				<xsl:value-of select="etdpub:clean-note-symbol($val)"/>
			</fo:inline>
			<fo:footnote-body>
				<fo:block xsl:use-attribute-sets="smaller">
					<fo:inline xsl:use-attribute-sets="footnote">
						<xsl:apply-templates select="tei:seg[@type='note-symbol']"/>
					</fo:inline>
					<xsl:apply-templates select="tei:p" mode="footnote"/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
	</xsl:template>

	<xsl:template match="tei:p" mode="footnote">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:seg[@type='note-symbol']">
		<xsl:value-of select="etdpub:clean-note-symbol(.)"/>
	</xsl:template>

	<!-- figure images -->
	<xsl:template match="tei:figure">
		<fo:block text-align="center" margin-bottom="1em">
			<!-- always ensure the capture is below the graphic -->
			<xsl:apply-templates select="tei:graphic"/>
			<xsl:apply-templates select="*[not(local-name()='graphic')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:figDesc|tei:caption|tei:figure/tei:p">
		<fo:block xsl:use-attribute-sets="smaller">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:graphic">
		<xsl:choose>
			<xsl:when test="matches(@url, 'https?://')">
				<fo:external-graphic src="url({@url})" content-width="scale-to-fit" scaling="uniform" max-width="50%"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:external-graphic src="url({concat($url, 'media/', $id, '/archive/', @url)})" content-width="scale-to-fit" scaling="uniform" max-width="50%"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- *********** QUOTED LETTERS *********** -->
	<xsl:template match="tei:floatingText">
		<fo:block xsl:use-attribute-sets="blockquote">
			<xsl:apply-templates select="descendant::tei:div"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:opener|tei:closer">
		<fo:block xsl:use-attribute-sets="p">
			<xsl:if test="self::tei:closer">
				<xsl:attribute name="text-align">right</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:dateline|tei:salute|tei:signed">
		<xsl:apply-templates/>
		<fo:block/>
	</xsl:template>

	<xsl:template match="tei:dateline/tei:date">
		<fo:block/>
		<xsl:apply-templates/>
	</xsl:template>

	<!-- GENERIC RENDERING -->
	<xsl:template match="@rend">
		<xsl:choose>
			<xsl:when test=". = 'hang'">
				<xsl:attribute name="start-indent">2em</xsl:attribute>
				<xsl:attribute name="text-indent">-2em</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'smallcaps'">
				<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'ul'">
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'bold'">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'italic'">
				<xsl:attribute name="font-style">italic</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'sup'">
				<xsl:attribute name="baseline-shift">super</xsl:attribute>
				<xsl:attribute name="font-size">1em</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'sub'">
				<xsl:attribute name="baseline-shift">sub</xsl:attribute>
				<xsl:attribute name="font-size">1em</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- *********** TITLE PAGE *********** -->
	<xsl:template match="tei:titlePage">
		<fo:block id="{generate-id()}" xsl:use-attribute-sets="frontmatter">
			<xsl:attribute name="page-break-after">always</xsl:attribute>
			<xsl:apply-templates mode="titlePage"/>
			<fo:block/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:docTitle" mode="titlePage">
		<fo:block font-size="28" font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:byline" mode="titlePage">
		<fo:block font-size="24" font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:docImprint" mode="titlePage">
		<fo:block margin-bottom=".5in" margin-top=".5in">
			<xsl:apply-templates mode="titlePage"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:publisher|tei:pubPlace|tei:idno" mode="titlePage">
		<xsl:value-of select="."/>
		<fo:block/>
	</xsl:template>

	<!-- *********** TITLE PAGE *********** -->
	<xsl:template match="tei:teiHeader">
		<fo:block xsl:use-attribute-sets="frontmatter">
			<xsl:attribute name="page-break-after">always</xsl:attribute>

			<xsl:apply-templates select="tei:fileDesc"/>
		</fo:block>
		<fo:block xsl:use-attribute-sets="frontmatter">
			<xsl:attribute name="page-break-after">always</xsl:attribute>

			<fo:block font-size="20" margin-bottom="1em">About this Digital Edition</fo:block>
			<fo:block xsl:use-attribute-sets="p" text-align="justify">
				<xsl:text>Since the dimensions, font, and other stylistic attributes of this document may differ 
					from the original printed work, the page numbers may not correspond precisely to the original.
					As a result, when citing this resource, be sure to state that you are citing the Digital Edition, with the date of access, and URI.</xsl:text>
			</fo:block>
			<fo:block font-size="16" margin-bottom="1em">Example</fo:block>
			<xsl:apply-templates select="tei:fileDesc" mode="citation"/>			
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt|tei:seriesStmt"/>
		<xsl:apply-templates select="tei:publicationStmt"/>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<fo:block font-size="24" font-weight="bold">
			<xsl:value-of select="tei:title"/>
		</fo:block>
		<xsl:for-each select="tei:author">
			<fo:block font-size="16">
				<xsl:value-of select="tei:name"/>
			</fo:block>
		</xsl:for-each>
		<xsl:if test="tei:editor">
			<fo:block font-size="16">
				<xsl:choose>
					<xsl:when test="count(tei:editor) = 1">
						<xsl:value-of select="tei:editor/tei:name"/>
						<xsl:text>, Ed.</xsl:text>
					</xsl:when>
					<xsl:when test="count(tei:editor) = 2">
						<xsl:value-of select="string-join(tei:editor/tei:name, ' and ')"/>
						<xsl:text>, Eds.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="tei:editor">
							<xsl:value-of select="tei:name"/>
							<xsl:text>, </xsl:text>
							<xsl:if test="position()=last()">
								<xsl:text>and </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>, Eds.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:seriesStmt">
		<fo:block margin-top=".5in" margin-bottom=".5in">
			<fo:block>
				<xsl:value-of select="tei:title"/>
			</fo:block>
			<xsl:apply-templates select="tei:biblScope"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:biblScope">
		<fo:block>
			<xsl:value-of select="concat(upper-case(substring(@unit, 1, 1)), substring(@unit, 2))"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="."/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<fo:block>
			<fo:block>
				<fo:external-graphic src="url('http://numismatics.org/digitallibrary/ui/images/ans-logo.png')" content-width="scale-to-fit" scaling="uniform" width="1.5in"/>
			</fo:block>
			<fo:block>
				<xsl:value-of select="tei:publisher/tei:name"/>
			</fo:block>
			<xsl:if test="tei:pubPlace">
				<fo:block>
					<xsl:value-of select="tei:pubPlace"/>
				</fo:block>
			</xsl:if>
			<xsl:if test="tei:date">
				<fo:block margin-top=".25in">
					<fo:block font-weight="bold">Original Publication:</fo:block>
					<fo:block>
						<xsl:value-of select="tei:date"/>
					</fo:block>
				</fo:block>
			</xsl:if>

			<!-- digital Edition -->
			<fo:block margin-top=".25in">
				<fo:block font-weight="bold">Digital Edition:</fo:block>
				<fo:block>
					<fo:basic-link external-destination="{concat($uri_space, $id)}" xsl:use-attribute-sets="hyperlink">
						<xsl:value-of select="concat($uri_space, $id)"/>
					</fo:basic-link>
				</fo:block>
				<fo:block>
					<xsl:value-of select="format-date(ancestor::tei:teiHeader/tei:revisionDesc/tei:change[last()]/@when, '[D] [MNn] [Y0001]')"/>
				</fo:block>

				<xsl:apply-templates select="tei:availability/tei:license"/>
			</fo:block>

		</fo:block>
	</xsl:template>

	<xsl:template match="tei:license">
		<xsl:variable name="imageUrl">
			<xsl:choose>
				<xsl:when test="contains(@target, 'http://creativecommons.org/licenses/by/')">http://i.creativecommons.org/l/by/3.0/88x31.png</xsl:when>
				<xsl:when test="contains(@target, 'http://creativecommons.org/licenses/by-nd/')">http://i.creativecommons.org/l/by-nd/3.0/88x31.png</xsl:when>
				<xsl:when test="contains(@target, 'http://creativecommons.org/licenses/by-nc-sa/')">http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png</xsl:when>
				<xsl:when test="contains(@target, 'http://creativecommons.org/licenses/by-sa/')">http://i.creativecommons.org/l/by-sa/3.0/88x31.png</xsl:when>
				<xsl:when test="contains(@target, 'http://creativecommons.org/licenses/by-nc/')">http://i.creativecommons.org/l/by-nc/3.0/88x31.png</xsl:when>
				<xsl:when test="contains(@target, 'http://creativecommons.org/licenses/by-nc-nd/')">http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<fo:block>
			<xsl:value-of select="$imageUrl"/>
			<!--<fo:external-graphic src="url({$imageUrl})" content-width="scale-to-fit" scaling="uniform" width="1in"/>-->
		</fo:block>
	</xsl:template>

	<!-- construct a citation -->
	<xsl:template match="tei:fileDesc" mode="citation">
		<fo:block xsl:use-attribute-sets="bibref">
			<xsl:apply-templates select="tei:titleStmt|tei:seriesStmt" mode="citation"/>
		<xsl:apply-templates select="tei:publicationStmt" mode="citation"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="concat($uri_space, $id)"/>
		<xsl:text> (accessed </xsl:text>
		<xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y0001]')"/>
		<xsl:text>).</xsl:text>			
		</fo:block>
		
	</xsl:template>

	<xsl:template match="tei:titleStmt" mode="citation">
		<!-- author or editor -->
		<xsl:choose>
			<xsl:when test="tei:author">
				<xsl:choose>
					<xsl:when test="count(tei:author) = 1">
						<xsl:value-of select="tei:author/tei:name"/>
					</xsl:when>
					<xsl:when test="count(tei:author) = 2">
						<xsl:value-of select="string-join(tei:author/tei:name, ' and ')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="tei:author">
							<xsl:value-of select="tei:name"/>
							<xsl:text>, </xsl:text>
							<xsl:if test="position()=last()">
								<xsl:text>and </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="tei:editor">
				<xsl:choose>
					<xsl:when test="count(tei:editor) = 1">
						<xsl:value-of select="tei:editor/tei:name"/>
						<xsl:text>, Ed.</xsl:text>
					</xsl:when>
					<xsl:when test="count(tei:editor) = 2">
						<xsl:value-of select="string-join(tei:editor/tei:name, ' and ')"/>
						<xsl:text>, Eds.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="tei:editor">
							<xsl:value-of select="tei:name"/>
							<xsl:text>, </xsl:text>
							<xsl:if test="position()=last()">
								<xsl:text>and </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>, Eds.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="tei:author or tei:editor">
			<xsl:text>, </xsl:text>
		</xsl:if>

		<!-- title -->
		<fo:inline>
			<xsl:attribute name="font-style">italic</xsl:attribute>
			<xsl:value-of select="tei:title"/>
		</fo:inline>
		<xsl:text> (Digital Edition), </xsl:text>
	</xsl:template>

	<xsl:template match="tei:seriesStmt" mode="citation">
		<xsl:value-of select="tei:title"/>
		<xsl:text> </xsl:text>
		<xsl:if test="tei:biblScope[@unit='volume']">
			<xsl:text>vol. </xsl:text>
			<xsl:value-of select="tei:biblScope[@unit='volume']"/>
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="tei:biblScope[@unit='issue']">
			<xsl:value-of select="tei:biblScope[@unit='issue']"/>
		</xsl:if>
		<xsl:text>, </xsl:text>
	</xsl:template>

	<xsl:template match="tei:publicationStmt" mode="citation">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="tei:pubPlace"/>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="tei:publisher/tei:name"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="tei:date"/>
		<xsl:text>).</xsl:text>
	</xsl:template>

	<!-- Table of Contents -->
	<xsl:template name="toc">
		<xsl:apply-templates select="tei:text" mode="toc"/>
	</xsl:template>

	<xsl:template match="tei:text" mode="toc">
		<xsl:if test="count(descendant::tei:div1) &gt; 0">
			<fo:block>
				<fo:block font-size="24px" font-weight="bold" text-align="center">Table of Contents</fo:block>
				<xsl:for-each select="*">
					<xsl:if test="count(tei:div1) &gt; 0">
						<fo:block font-size="16px" font-weight="bold">
							<xsl:value-of select="upper-case(local-name())"/>
						</fo:block>
						<fo:list-block>
							<xsl:apply-templates select="tei:div1|tei:titlePage" mode="toc"/>
						</fo:list-block>
					</xsl:if>
				</xsl:for-each>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:titlePage|tei:div1|tei:div2" mode="toc">
		<xsl:if test="not(@type='cover')">
			<fo:list-item>
				<fo:list-item-label>
					<fo:block>
						<!--<xsl:if test="ancestor::tei:body">
							<xsl:choose>
								<xsl:when test="parent::tei:body">
									<xsl:value-of select="position()"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(count(parent::node()/preceding-sibling::tei:div1) + 1, '.', position())"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>-->
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body >
					<fo:block text-align="justify" text-align-last="justify">
						<fo:basic-link internal-destination="{generate-id(.)}">
							<xsl:choose>
								<xsl:when test="tei:head">
									<xsl:value-of select="tei:head"/>
								</xsl:when>
								<xsl:when test="self::tei:titlePage">Title Page</xsl:when>
								<xsl:otherwise>[No title]</xsl:otherwise>
							</xsl:choose>
							<fo:leader leader-pattern="dots"/>
							<fo:page-number-citation ref-id="{generate-id(.)}"/>
						</fo:basic-link>
						<xsl:if test="child::tei:div2">
							<fo:list-block margin-left="2em">
								<xsl:apply-templates select="tei:div2" mode="toc"/>
							</fo:list-block>
						</xsl:if>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</xsl:if>

	</xsl:template>

	<!-- ************* FUNCTIONS ************** -->
	<xsl:function name="etdpub:font-size">
		<xsl:param name="level"/>

		<xsl:choose>
			<xsl:when test="$level=1">28</xsl:when>
			<xsl:when test="$level=2">24</xsl:when>
			<xsl:when test="$level=3">20</xsl:when>
			<xsl:when test="$level=4">16</xsl:when>
			<xsl:when test="$level=5">14</xsl:when>
			<xsl:when test="$level=6">12</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="etdpub:clean-note-symbol">
		<xsl:param name="symbol"/>

		<xsl:choose>
			<xsl:when test="substring($symbol, string-length($symbol), 1) = '.'">
				<xsl:value-of select="substring($symbol, 1, string-length($symbol) - 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$symbol"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- ************* ATTRIBUTE SETS ************** -->
	<xsl:attribute-set name="doc-font">
		<xsl:attribute name="font-family">Times, "Times New Roman", Georgia, serif;</xsl:attribute>
		<xsl:attribute name="font-size">11px</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="layout">
		<xsl:attribute name="margin">1in</xsl:attribute>
		<xsl:attribute name="page-width">8.5in</xsl:attribute>
		<xsl:attribute name="page-height">11in</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="p">
		<xsl:attribute name="margin-bottom">1em</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="blockquote">
		<xsl:attribute name="space-before">1em</xsl:attribute>
		<xsl:attribute name="space-after">1em</xsl:attribute>
		<xsl:attribute name="margin-left">2em</xsl:attribute>
		<xsl:attribute name="margin-right">2em</xsl:attribute>
		<xsl:attribute name="font-size">smaller</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="smaller">
		<xsl:attribute name="font-size">1em</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="frontmatter">
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="margin-top">33%</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hyperlink">
		<xsl:attribute name="color">black</xsl:attribute>
		<xsl:attribute name="text-decoration">underline</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="footnote">
		<xsl:attribute name="baseline-shift">super</xsl:attribute>
		<xsl:attribute name="font-size">9px</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="bibref">
		<xsl:attribute name="text-align">justify</xsl:attribute>
		<xsl:attribute name="start-indent">2em</xsl:attribute>
		<xsl:attribute name="text-indent">-2em</xsl:attribute>
		<xsl:attribute name="margin-bottom">1em</xsl:attribute>
	</xsl:attribute-set>
</xsl:stylesheet>
