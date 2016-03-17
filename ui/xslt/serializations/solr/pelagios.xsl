<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:oa="http://www.w3.org/ns/oa#"
	xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:nm="http://nomisma.org/id/" version="2.0">

	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id_space" select="if (/content/config/ark/@enabled='true') then concat('ark:/', /content/config/ark/naan) else 'id'"/>

	<xsl:template match="/">
		<rdf:RDF>
			<foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
				<foaf:name>
					<xsl:value-of select="/content/config/publisher"/>
				</foaf:name>
			</foaf:Organization>
			<xsl:apply-templates select="//doc[not(arr[@name='genre_uri']/str = 'http://vocab.getty.edu/aat/300265554')]"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="id" select="str[@name='id']"/>
		<xsl:variable name="annotation" select="if (contains($id, '#')) then replace($id, '#', '/') else $id"/>
		
		<xsl:variable name="timestamp" select="date[@name='timestamp']"/>
		<pelagios:AnnotatedThing rdf:about="{$url}pelagios.rdf#{$annotation}">
			<dcterms:title>
				<xsl:value-of select="str[@name='title']"/>
			</dcterms:title>
			<foaf:homepage rdf:resource="{concat($url, $id_space, '/', $id)}"/>
			<xsl:for-each select="distinct-values(arr[@name='genre_uri']/str)">
				<dcterms:type rdf:resource="{.}"/>
			</xsl:for-each>
			<xsl:apply-templates select="str[@name='isPartOf']">
				<xsl:with-param name="doc" select="substring-before($id, '#')"/>
			</xsl:apply-templates>
		</pelagios:AnnotatedThing>
		<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
			<oa:Annotation rdf:about="{$url}pelagios.rdf#{$annotation}/annotations/{format-number(position(), '000')}">
				<oa:hasBody rdf:resource="{.}#this"/>
				<oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$annotation}"/>
				<pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#attestsTo"/>
				<oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
				<oa:annotatedAt rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="$timestamp"/>
				</oa:annotatedAt>
			</oa:Annotation>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="str[@name='isPartOf']">
		<xsl:param name="doc"/>
		
		<dcterms:isPartOf>
			<xsl:attribute name="rdf:resource">
				<xsl:choose>
					<xsl:when test="contains(., '#')">
						<xsl:value-of select="concat($url, $id_space, '/', $doc, .)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($url, $id_space, '/', $doc)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</dcterms:isPartOf>
	</xsl:template>
</xsl:stylesheet>
