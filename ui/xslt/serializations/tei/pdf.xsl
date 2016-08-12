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
		<fo:root font-size="12px" font-family="'times new roman', times, serif">
			<fo:layout-master-set>
				<fo:simple-page-master margin-right="1in" margin-left="1in" margin-bottom="1in" margin-top="1in" page-width="8in" page-height="11in" master-name="content">
					<fo:region-body region-name="body" margin-bottom=".5in"/>
					<fo:region-after region-name="footer" extent=".5in"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="content">
				<fo:title>
					<xsl:value-of select="//tei:titleStmt/tei:title"/>
				</fo:title>
				<fo:static-content flow-name="footer">
					<fo:block font-size="85%" text-align="center">
						<fo:page-number/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="body">
					<xsl:apply-templates select="tei:text"/>
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>

	<xsl:template match="tei:text">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:front|tei:body|tei:back">
		<xsl:apply-templates/>
	</xsl:template>



	<xsl:template match="*[starts-with(local-name(), 'div')]">
		<fo:block margin-bottom="10px;">
			<xsl:choose>
				<xsl:when test="(parent::tei:front and following::tei:titlePage) or self::tei:titlePage">
					<xsl:attribute name="text-align">center</xsl:attribute>
					<xsl:attribute name="margin-top">33%</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="text-align">justify</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates/>
			<xsl:if test="self::tei:div1">
				<fo:block page-break-before="always"/>
			</xsl:if>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:head">
		<xsl:variable name="size">
			<xsl:choose>
				<xsl:when test="starts-with(parent::node()/local-name(), 'div')">
					<xsl:variable name="level" select="number(substring-after(parent::node()/local-name(), 'div'))"/>

					<xsl:choose>
						<xsl:when test="$level=1">32</xsl:when>
						<xsl:when test="$level=2">28</xsl:when>
						<xsl:when test="$level=3">24</xsl:when>
						<xsl:when test="$level=4">20</xsl:when>
						<xsl:when test="$level=5">16</xsl:when>
						<xsl:when test="$level=6">14</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::tei:figure">
					<xsl:variable name="level" select="number(substring(ancestor::*[starts-with(local-name(), 'div')][1]/local-name(), 4, 1))"/>

					<xsl:choose>
						<xsl:when test="$level=1">32</xsl:when>
						<xsl:when test="$level=2">28</xsl:when>
						<xsl:when test="$level=3">24</xsl:when>
						<xsl:when test="$level=4">20</xsl:when>
						<xsl:when test="$level=5">16</xsl:when>
						<xsl:when test="$level=6">14</xsl:when>
					</xsl:choose>
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
		<fo:block text-align="center" margin-bottom="10px">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:p">
		<fo:block margin-bottom="10px">
			<xsl:apply-templates select="node()|@*"/>
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

	<!--  quotes -->
	<xsl:template match="tei:quote">
		<fo:block space-before="6pt" space-after="6pt" margin-left="2em" margin-right="2em" margin-bottom="10px">
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
		<fo:block margin-bottom="10px">
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
				<fo:table-and-caption>
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
				<fo:table margin-bottom="10px">
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
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<xsl:template match="tei:list">
		<fo:list-block>
			<xsl:apply-templates/>
		</fo:list-block>
	</xsl:template>

	<xsl:template match="tei:item">
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block>•</fo:block>
			</fo:list-item-label>
			<fo:list-item-body>
				<fo:block>
					<xsl:apply-templates select="node()|@*"/>
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
				<fo:basic-link external-destination="url({$entity//tei:idno[@type='URI']})" color="blue" text-decoration="underline">
					<xsl:value-of select="."/>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:ref">
		<fo:basic-link color="blue" text-decoration="underline">
			<xsl:choose>
				<xsl:when test="contains(@target, '#')">
					<xsl:attribute name="internal-destination" select="substring-after(@target, '#')"/>


				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="external-destination">
						<xsl:value-of select="concat('url(', @target, ')')"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</fo:basic-link>
	</xsl:template>

	<!-- footnote -->
	<xsl:template match="tei:note[@place='foot']">
		<fo:footnote>
			<fo:inline font-size="75%" baseline-shift="super">
				<xsl:value-of select="tei:seg[@type='note-symbol']"/>
			</fo:inline>
			<fo:footnote-body font-size="75%" font-weight="normal" font-style="normal" text-align="justify" margin-left="0pc">
				<fo:block>
					<fo:inline font-size="75%" baseline-shift="super">
						<xsl:value-of select="tei:seg[@type='note-symbol']"/>
					</fo:inline>
					<xsl:apply-templates select="*[not(self::tei:seg[@type='note-symbol'])]"/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
	</xsl:template>

	<!-- figure images -->
	<xsl:template match="tei:figure">
		<fo:block text-align="center">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:figDesc|tei:caption">
		<fo:block color="gray">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:graphic">
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="parent::tei:figure/tei:figureDesc">
					<xsl:value-of select="normalize-space(parent::tei:figure/tei:figureDesc)"/>
				</xsl:when>
				<xsl:when test="parent::tei:figure/tei:p">
					<xsl:value-of select="normalize-space(parent::tei:figure/tei:p[1])"/>
				</xsl:when>
				<xsl:when test="parent::tei:figure/@n">
					<xsl:value-of select="parent::tei:figure/@n"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="matches(@url, 'https?://')">
				<fo:external-graphic src="url({@url})"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:external-graphic src="url({concat($url, 'media/', $id, '/archive/', @url)})" content-width="scale-to-fit" scaling="uniform" max-width="50%"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="@rend">
		<xsl:choose>
			<xsl:when test=". = 'hang'">
				<xsl:attribute name="padding-left">2em</xsl:attribute>
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
				<xsl:attribute name="vertical-align">sup</xsl:attribute>
				<xsl:attribute name="font-size">smaller</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'sub'">
				<xsl:attribute name="vertical-align">sub</xsl:attribute>
				<xsl:attribute name="font-size">smaller</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- *********** TITLE PAGE *********** -->
	<xsl:template match="tei:titlePage">
		<fo:block id="{if (@xml:id) then @xml:id else generate-id()}" text-align="center" margin-top="33%">
			<xsl:apply-templates mode="titlePage"/>
			<fo:block/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:docTitle" mode="titlePage">
		<fo:block font-size="32" font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:byline" mode="titlePage">
		<fo:block font-size="28" font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:docImprint" mode="titlePage">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:publisher|tei:pubPlace|tei:idno" mode="titlePage">
		<xsl:value-of select="."/>
		<fo:block/>
	</xsl:template>

	<!-- suppress cover -->
	<xsl:template match="tei:div1[@type='cover']"/>

</xsl:stylesheet>
