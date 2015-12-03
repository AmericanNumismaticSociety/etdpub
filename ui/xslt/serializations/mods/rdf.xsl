<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:void="http://rdfs.org/ns/void#" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="xsl xs mods xlink xml" version="2.0">

	<xsl:variable name="url" select="/content/config/url"/>

	<!-- ***************** MODS-TO-RDF ******************-->
	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="//mods:mods"/>
		</rdf:RDF>		
	</xsl:template>

	<xsl:template match="mods:mods">
		<dcterms:PhysicalResource rdf:about="{concat($url, 'id/', mods:recordInfo/mods:recordIdentifier)}">
			<dcterms:title>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dcterms:title>
			<xsl:for-each select="mods:name">
				<dcterms:creator>
					<xsl:choose>
						<xsl:when test="@valueURI">
							<xsl:attribute name="rdf:resource">
								<xsl:value-of select="@valueURI"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="mods:namePart"/>
						</xsl:otherwise>
					</xsl:choose>
				</dcterms:creator>
			</xsl:for-each>
			<xsl:apply-templates select="mods:abstract"/>
			<xsl:apply-templates select="mods:originInfo"/>
			<xsl:apply-templates select="mods:physicalDescription"/>
			<xsl:apply-templates select="mods:accessCondition"/>
			<xsl:apply-templates select="mods:relatedItem[@type='host']"/>
			<xsl:apply-templates select="mods:location/mods:url" mode="doc-link"/>
			<xsl:apply-templates select="mods:genre|mods:subject/*" mode="topic"/>
			<void:inDataset rdf:resource="{$url}"/>
		</dcterms:PhysicalResource>
	</xsl:template>

	<xsl:template match="mods:originInfo">
		<xsl:choose>
			<xsl:when test="mods:dateIssued[not(@point)]">
				<xsl:apply-templates select="mods:dateIssued"/>
			</xsl:when>
			<xsl:when test="mods:dateIssued[@point]">
				<dcterms:temporal>
					<dcterms:PeriodOfTime>
						<xsl:apply-templates select="mods:dateIssued"/>
					</dcterms:PeriodOfTime>
				</dcterms:temporal>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="mods:publisher">
			<dcterms:publisher>
				<xsl:value-of select="mods:publisher"/>
			</dcterms:publisher>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:url" mode="doc-link">
		<edm:hasView rdf:resource="{concat($url, .)}"/>
	</xsl:template>

	<xsl:template match="mods:date|mods:dateIssued">
		<dcterms:issued>
			<xsl:choose>
				<xsl:when test=". castable as xs:date">
					<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#date</xsl:attribute>
				</xsl:when>
				<xsl:when test=". castable as xs:gYearMonth">
					<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:attribute>
				</xsl:when>
				<xsl:when test=". castable as xs:gYear">
					<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#gYear</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="."/>
		</dcterms:issued>
	</xsl:template>

	<xsl:template match="mods:relatedItem[@type='host']">
		<dcterms:isPartOf rdf:resource="{concat($url, 'id/', mods:identifier)}"/>
		<xsl:apply-templates select="mods:part/mods:date"/>
	</xsl:template>

	<xsl:template match="mods:abstract">
		<dcterms:abstract>
			<xsl:value-of select="."/>
		</dcterms:abstract>
	</xsl:template>

	<xsl:template match="mods:accessCondition">
		<dcterms:rights rdf:resource="{@xlink:href}"/>
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:apply-templates select="mods:form|mods:internetMediaType"/>
		<xsl:if test="mods:extent">
			<dcterms:extent>
				<xsl:value-of select="mods:extent"/>
			</dcterms:extent>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:form|mods:internetMediaType">
		<dcterms:format>
			<xsl:value-of select="."/>
		</dcterms:format>
	</xsl:template>

	<xsl:template match="*" mode="topic">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='form'">dcterms:format</xsl:when>
				<xsl:when test="local-name()='genre'">dcterms:type</xsl:when>
				<xsl:when test="local-name()='geographic'">dcterms:coverage</xsl:when>
				<xsl:otherwise>dcterms:subject</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>

		<xsl:element name="{$element}" namespace="http://purl.org/dc/terms/">
			<xsl:choose>
				<xsl:when test="string(@valueURI)">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="@valueURI"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="if (mods:namePart) then mods:namePart else ."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
