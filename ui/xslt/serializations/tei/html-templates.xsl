<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:epub="http://www.idpf.org/2007/ops" xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="*[starts-with(local-name(), 'div')]">
		<section epub:type="{@type}" id="{if (@xml:id) then @xml:id else generate-id()}">
			<xsl:apply-templates/>
			<xsl:if test="self::tei:div1">
				<hr/>
			</xsl:if>			
		</section>
	</xsl:template>

	<!-- minor elements -->
	<xsl:template match="tei:head">
		<header>
			<xsl:choose>
				<xsl:when test="starts-with(parent::node()/local-name(), 'div')">
					<xsl:element name="h{number(substring-after(parent::node()/local-name(), 'div')) + 1}">
						<xsl:apply-templates/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<span class="otherHead">
						<xsl:apply-templates/>
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</header>
	</xsl:template>

	<xsl:template match="tei:p">
		<p>
			<!-- suppress figures from within the paragraph, put them afterwards -->
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
		</p>
		<xsl:apply-templates select="tei:figure"/>
	</xsl:template>

	<xsl:template match="tei:lb">
		<br/>
	</xsl:template>

	<xsl:template match="tei:hi[not(parent::tei:head)]">
		<xsl:choose>
			<xsl:when test="@rend='bold'">
				<strong>
					<xsl:apply-templates/>
				</strong>
			</xsl:when>
			<xsl:when test="@rend='italic'">
				<i>
					<xsl:apply-templates/>
				</i>
			</xsl:when>
			<xsl:when test="@rend='sup'">
				<sup>
					<xsl:apply-templates/>
				</sup>
			</xsl:when>
			<xsl:when test="@rend='sub'">
				<sub>
					<xsl:apply-templates/>
				</sub>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--<xsl:template match="tei:pb">
		<span class="page-number" id="page-{@n}">Page <xsl:value-of select="@n"/></span>
	</xsl:template>-->

	<!-- figures -->
	<xsl:template match="tei:figure"/>

	<!-- tables and lists-->
	<xsl:template match="tei:table">
		<table class="table table-striped">
			<xsl:if test="tei:head">
				<caption>
					<xsl:value-of select="tei:head"/>
				</caption>
			</xsl:if>
			<tbody>
				<xsl:apply-templates select="tei:row"/>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="tei:row">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>

	<xsl:template match="tei:cell">
		<td>
			<xsl:apply-templates/>
		</td>
	</xsl:template>

	<xsl:template match="tei:list">
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="tei:item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!--  quotes -->
	<xsl:template match="tei:quote">
		<blockquote>
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
		</blockquote>
		<xsl:apply-templates select="tei:figure"/>
	</xsl:template>

	<xsl:template match="tei:q">
		<q>
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
		</q>
		<xsl:apply-templates select="tei:figure"/>
	</xsl:template>

	<!-- address -->
	<xsl:template match="tei:address">
		<div>
			<xsl:for-each select="tei:addrLine">
				<xsl:value-of select="."/>
				<br/>
			</xsl:for-each>
		</div>
	</xsl:template>

	<!-- linking -->
	<xsl:template match="tei:ref">
		<a href="{@target}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- suppress footnotes from the body -->
	<xsl:template match="tei:note[@place]"/>

	<xsl:template match="tei:note[@place]" mode="endnote">
		<li>
			<a id="{@xml:id}"/>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!-- name linking -->
	<xsl:template match="tei:name[@corresp]">
		<xsl:variable name="id" select="substring-after(@corresp, '#')"/>
		<xsl:variable name="entity" as="element()*">
			<xsl:copy-of select="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc//*[starts-with(local-name(), 'list')]/*[@xml:id=$id]"/>
		</xsl:variable>

		<a href="{$display_path}results?q={if (@type='pname') then 'name' else 'place'}_facet:&#x022;{$entity//tei:*[contains(local-name(), 'Name')]}&#x022;">
			<xsl:value-of select="."/>
		</a>
		<a href="{$entity//tei:idno[@type='URI']}" title="{$entity//*[contains(local-name(), 'Name')]}" class="external-link">
			<img src="{$display_path}ui/images/external.png" alt="External Link"/>
		</a>
	</xsl:template>

	<!-- figure images -->
	<xsl:template match="tei:figure">
		<div class="figure">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="tei:graphic">
		<xsl:variable name="src" select="if(matches(@url, 'https?://')) then @url else concat($display_path, 'media/', $id, '/', @url)"/>
		<img src="{$src}" alt="figure" class="img-rounded"/>
	</xsl:template>

	<!-- *********** TITLE PAGE *********** -->
	<xsl:template match="tei:titlePage">
		<section epub:type="titlepage" id="{if (@xml:id) then @xml:id else generate-id()}" class="text-center">
			<xsl:apply-templates/>
			<hr/>
		</section>
	</xsl:template>

	<xsl:template match="tei:docTitle">
		<h1>
			<xsl:apply-templates/>
		</h1>
	</xsl:template>

	<xsl:template match="tei:byline">
		<h2>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>

	<xsl:template match="tei:docImprint">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:publisher|tei:pubPlace|tei:idno">
		<xsl:value-of select="."/>
		<br/>
	</xsl:template>

</xsl:stylesheet>
