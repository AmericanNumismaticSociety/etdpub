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
				<fo:simple-page-master xsl:use-attribute-sets="layout" master-name="content">
					<fo:region-body region-name="body" margin-bottom=".5in"/>
					<fo:region-after region-name="footer" extent=".5in"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="content">
				<fo:title>
					<xsl:value-of select="//tei:titleStmt/tei:title"/>
				</fo:title>
				<fo:static-content flow-name="footer">
					<fo:block font-size="smaller" text-align="center">
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
		<fo:block>
			<xsl:if test="self::tei:div1">
				<xsl:attribute name="page-break-after">always</xsl:attribute>
			</xsl:if>
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
			
			<!--<xsl:if test="self::tei:div1">
				<fo:block page-break-before="always"/>
			</xsl:if>-->
		</fo:block>
	</xsl:template>

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
			<fo:list-item-label start-indent="1em">
				<fo:block>
					<xsl:choose>
						<xsl:when test="@n">
							<xsl:value-of select="@n"/>
						</xsl:when>
						<xsl:otherwise>•</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="2em">
				<fo:block>
					<xsl:apply-templates select="node()|@rend"/>
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
		<xsl:choose>
			<xsl:when test="contains(@target, '#')">
				<xsl:variable name="noteId" select="substring-after(@target, '#')"/>
				
				<xsl:apply-templates select="//tei:note[@xml:id=$noteId]" mode="footnote"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:basic-link color="blue" text-decoration="underline">
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
		<fo:footnote>
			<fo:inline>
				<xsl:attribute name="baseline-shift">sup</xsl:attribute>
				<xsl:attribute name="font-size">10px</xsl:attribute>
				<xsl:value-of select="."/>
			</fo:inline>
			<fo:footnote-body>
				<fo:block xsl:use-attribute-sets="smaller">
					<fo:inline>
						<xsl:attribute name="baseline-shift">super</xsl:attribute>							
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
	
	

	<!-- figure images -->
	<xsl:template match="tei:figure">
		<fo:block text-align="center">
			<xsl:apply-templates/>
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
				<fo:external-graphic src="url({@url})"/>
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
				<xsl:attribute name="baseline-shift">super</xsl:attribute>
				<xsl:attribute name="font-size">10px</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'sub'">
				<xsl:attribute name="baseline-shift">sub</xsl:attribute>
				<xsl:attribute name="font-size">10px</xsl:attribute>
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
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:publisher|tei:pubPlace|tei:idno" mode="titlePage">
		<xsl:value-of select="."/>
		<fo:block/>
	</xsl:template>

	<!-- suppress cover -->
	<xsl:template match="tei:div1[@type='cover']"/>

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
		<xsl:attribute name="margin-bottom">10px</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="blockquote">
		<xsl:attribute name="space-before">10px</xsl:attribute>
		<xsl:attribute name="space-after">10px</xsl:attribute>
		<xsl:attribute name="margin-left">2em</xsl:attribute>
		<xsl:attribute name="margin-right">2em</xsl:attribute>
		<xsl:attribute name="font-size">smaller</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="smaller">
		<xsl:attribute name="font-size">10px</xsl:attribute>
	</xsl:attribute-set>
</xsl:stylesheet>
