<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	
	<!-- config variable -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id_space" select="if (/content/config/ark/@enabled='true') then concat('ark:/', /content/config/ark/naan) else 'id'"/>
	
	<!-- request params -->
	<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>	
	<xsl:param name="start" select="doc('input:params')/request/parameters/parameter[name='start']/value"/>	
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:param name="rows" as="xs:integer">100</xsl:param>

	<xsl:template match="/">
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="floor($numFound div 100) * 100"/>
		<xsl:variable name="next" select="$start_var + 100"/>


		<feed xmlns="http://www.w3.org/2005/Atom">
			<title>
				<xsl:value-of select="/content/config/title"/>
			</title>
			<link href="{/content/config/url}"/>
			<link href="{/content/config/url}feed/?q={$q}" rel="self"/>

			<xsl:if test="$next &lt; $last">
				<link rel="next" href="{$url}feed/?q={$q}&amp;start={$next}"/>
			</xsl:if>
			<link rel="last" href="{$url}feed/?q={$q}&amp;start={$last}"/>

			<author>
				<name>
					<xsl:value-of select="/content/config/title"/>
				</name>
			</author>

			<xsl:apply-templates select="descendant::doc"/>
		</feed>

	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="objectUri" select="concat($url, $id_space, '/', str[@name='id'])"/>
		
		<entry>
			<title>
				<xsl:value-of select="str[@name='title']"/>
			</title>
			<link href="{$objectUri}"/>
			<link rel="alternate" type="text/xml" href="{$objectUri}.xml"/>
			<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>
			<xsl:if test="str[@name='media_url'] and str[@name='media_type']">
				<content type="{str[@name='media_type']}" href="{concat($url, str[@name='media_url'])}"/>	
			</xsl:if>
			<xsl:if test="arr[@name='genre_facet']/str[1] = 'e-books'">
				<link rel="alternate" type="application/pdf" href="{$objectUri}/pdf"/>
				<link rel="alternate" type="application/epub+zip" href="{$objectUri}.epub"/>
			</xsl:if>
			<id>
				<xsl:value-of select="$objectUri"/>
			</id>			
			<xsl:for-each select="arr[@name='creator_facet']/str">
				<author>
					<name>
						<xsl:value-of select="."/>
					</name>
				</author>				
			</xsl:for-each>
			
			<summary>
				<xsl:value-of select="str[@name='abstract']"/>
			</summary>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>
		</entry>
	</xsl:template>
</xsl:stylesheet>
