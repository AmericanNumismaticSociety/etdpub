<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub"
	xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="tei xlink etdpub xs" version="2.0">

	<xsl:template match="tei:div2">
		<xsl:variable name="frag"
			select="concat(parent::node()/parent::node()/local-name(), '-', format-number(count(../preceding-sibling::tei:div1) + 1, '000'), '-', format-number(count(preceding-sibling::tei:div2) + 1, '000'))"/>

		<section epub:type="{@type}">
			<a id="{format-number(count(preceding-sibling::tei:div2) + 1, '000')}"/>
			<xsl:apply-templates/>
		</section>
	</xsl:template>

	<xsl:template match="tei:div3|tei:div4|tei:div5|tei:div6">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!-- minor elements -->
	<xsl:template match="tei:head">
		<header>
			<xsl:choose>
				<xsl:when test="starts-with(parent::node()/local-name(), 'div')">
					<xsl:element
						name="h{number(substring-after(parent::node()/local-name(), 'div')) + 1}">
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
		<xsl:apply-templates select="descendant::tei:figure"/>
	</xsl:template>

	<xsl:template match="tei:lb">
		<br/>
	</xsl:template>

	<xsl:template match="tei:hi[not(parent::tei:head)]">
		<span class="rend-{@rend}">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!--<xsl:template match="tei:pb">
		<span class="page-number" id="page-{@n}">Page <xsl:value-of select="@n"/></span>
	</xsl:template>-->

	<!-- name linking -->
	<xsl:template match="tei:name[@corresp]">
		<xsl:variable name="id" select="substring-after(@corresp, '#')"/>
		<xsl:variable name="entity" as="element()*">
			<xsl:copy-of
				select="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc//*[starts-with(local-name(), 'list')]/*[@xml:id=$id]"
			/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($entity//tei:idno[@type='URI']) &gt; 0">
				<a href="{$entity//tei:idno[@type='URI']}"
					title="{$entity//*[contains(local-name(), 'Name')]}" class="external-link">
					<xsl:value-of select="."/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<!-- tables and lists-->
	<xsl:template match="tei:table">
		<table epub:type="table">
			<xsl:if test="tei:head">
				<caption>
					<xsl:value-of select="tei:head"/>
				</caption>
			</xsl:if>
			<xsl:apply-templates select="tei:row"/>
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
	<!-- suppress figures from quotes -->
	<xsl:template match="tei:quote">
		<blockquote>
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
		</blockquote>
	</xsl:template>

	<xsl:template match="tei:q">
		<q>
			<xsl:apply-templates select="node()[not(local-name()='figure')]"/>
		</q>
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

	<!-- figure images -->
	<xsl:template match="tei:figure">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="tei:caption|tei:figDesc">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="tei:graphic">
		<xsl:variable name="src" select="concat('images/', tokenize(@url, '/')[last()])"/>
		<img src="{$src}" alt="figure"/>
	</xsl:template>

	<!-- *********** TITLE PAGE *********** -->
	<xsl:template match="tei:docTitle" mode="titlePage">
		<h1>
			<xsl:apply-templates/>
		</h1>
	</xsl:template>

	<xsl:template match="tei:byline" mode="titlePage">
		<h2>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>

	<xsl:template match="tei:docImprint" mode="titlePage">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:publisher|tei:pubPlace|tei:idno" mode="titlePage">
		<xsl:value-of select="."/>
		<br/>
	</xsl:template>
	
	<!-- bibl -->
	<xsl:template match="tei:listBibl">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:bibl">
		<xsl:choose>
			<xsl:when test="parent::tei:listBibl">
				<div class="bibl">
					<xsl:call-template name="bibl"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="bibl"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="bibl">
		<xsl:apply-templates select="node()[not(tei:idno[@type='URI'])]"/>
		<xsl:if test="tei:idno[@type='URI']">
			<xsl:text> - </xsl:text>
			<a href="{tei:idno[@type='URI']}" title="{tei:idno[@type='URI']}">
				<xsl:value-of select="tei:idno[@type='URI']"/>
			</a>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
