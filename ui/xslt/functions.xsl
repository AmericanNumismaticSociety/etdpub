<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<!-- ********************************** FUNCTIONS ************************************ -->

	<xsl:function name="etdpub:normalize_fields">
		<xsl:param name="field"/>
		<xsl:choose>
			<xsl:when test="contains($field, '_uri')">
				<xsl:variable name="name" select="substring-before($field, '_uri')"/>
				<xsl:value-of select="etdpub:field_to_text($name)"/>
				<xsl:text> URI</xsl:text>
			</xsl:when>
			<xsl:when test="contains($field, '_facet')">
				<xsl:variable name="name" select="substring-before($field, '_facet')"/>
				<xsl:value-of select="etdpub:field_to_text($name)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_text')">
				<xsl:variable name="name" select="substring-before($field, '_text')"/>
				<xsl:value-of select="etdpub:field_to_text($name)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_min') or contains($field, '_max')">
				<xsl:variable name="name" select="substring-before($field, '_m')"/>
				<xsl:value-of select="etdpub:normalize_fields($name)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_display')">
				<xsl:variable name="name" select="substring-before($field, '_display')"/>
				<xsl:value-of select="etdpub:field_to_text($name)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="etdpub:field_to_text($field)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="etdpub:field_to_text">
		<xsl:param name="field"/>

		<xsl:choose>
			<xsl:when test="$field = 'field_of_numismatics'">Field of Numismatics</xsl:when>
			<xsl:when test="$field = 'timestamp'">Date Record Modified</xsl:when>
			<xsl:when test="$field = 'fulltext'">Keyword</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(upper-case(substring($field, 1, 1)), substring($field, 2))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="etdpub:normalize_property">
		<xsl:param name="uri"/>

		<xsl:variable name="namespaces" as="item()*">
			<namespaces>
				<namespace prefix="ecrm" uri="http://erlangen-crm.org/current/"/>
				<namespace prefix="dcterms" uri="http://purl.org/dc/terms/"/>
				<namespace prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
				<namespace prefix="geo" uri="http://www.w3.org/2003/01/geo/wgs84_pos#"/>
				<namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
				<namespace prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
				<namespace prefix="xsd" uri="http://www.w3.org/2001/XMLSchema#"/>
			</namespaces>
		</xsl:variable>

		<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>

	</xsl:function>
</xsl:stylesheet>
