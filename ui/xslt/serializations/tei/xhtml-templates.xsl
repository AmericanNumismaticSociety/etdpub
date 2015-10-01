<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="tei xlink etdpub xs" version="2.0">
	
	<xsl:template match="tei:div1|tei:div2">
		<xsl:variable name="position" select="if (local-name()='div1') then position() else count(preceding-sibling::node()[local-name()='div2']) + 1"/>
		
		<xsl:variable name="frag">
			<xsl:choose>
				<xsl:when test="@xml:id">
					<xsl:value-of select="@xml:id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="local-name()='div1'">
							<xsl:value-of select="concat(@type, format-number($position, '000'))"/>
						</xsl:when>
						<xsl:when test="local-name()='div2'">
							<xsl:value-of select="concat(parent::node()/@type, format-number(count(../preceding-sibling::node()[local-name()='div1']) + 1, '000'), '_', @type, format-number($position, '000'))"/>
						</xsl:when>
					</xsl:choose>					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<section epub:type="{@type}">
			<xsl:if test="local-name()='div1' or local-name()='div2'">
				<a id="{$frag}"/>
			</xsl:if>
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
			<xsl:apply-templates/>
		</p>
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
		<div class="figure">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="tei:graphic">
		<xsl:variable name="src" select="concat('images/', tokenize(@url, '/')[last()])"/>
		<img src="{$src}" alt="figure"/>
	</xsl:template>
</xsl:stylesheet>
