<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nmo="http://nomisma.org/ontology#" version="2.0" exclude-result-prefixes="#all">

	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nmo="http://nomisma.org/ontology#">

			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::*[contains(@valueURI, 'nomisma.org')]/@valueURI)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="//mods:mods"/>
		</add>
	</xsl:template>

	<xsl:template match="mods:mods">
		<doc>
			<field name="id">
				<xsl:value-of select="//mods:recordIdentifier"/>
			</field>
			<field name="title" update="add">
				<xsl:value-of select="//mods:title"/>
			</field>
			<field name="author" update="add">
				<xsl:value-of select="//mods:namePart"/>
			</field>
			<field name="university" update="add">
				<xsl:value-of select="//mods:publisher"/>
			</field>
			<field name="timestamp" update="set">
				<xsl:value-of select="if (contains(string(current-dateTime()), 'Z')) then current-dateTime() else concat(string(current-dateTime()), 'Z')"/>
			</field>
			<field name="date" update="add">
				<xsl:value-of select="//mods:dateCreated"/>
			</field>
			<field name="abstract" update="add">
				<xsl:value-of select="//mods:abstract"/>
			</field>
			<field name="media_url" update="add">
				<xsl:value-of select="mods:location/mods:url"/>
			</field>

			<xsl:for-each select="mods:language">
				<field name="language" update="set">
					<xsl:value-of select="mods:languageTerm"/>
				</field>
			</xsl:for-each>

			<!-- subject facets -->
			<xsl:for-each select="mods:subject/*">
				<field name="{local-name()}_facet" update="set">
					<xsl:value-of select="."/>
				</field>
				<xsl:if test="string(@valueURI)">
					<field name="{local-name()}_uri" update="set">
						<xsl:value-of select="@valueURI"/>
					</field>
				</xsl:if>

				<!-- Pleiades URIs -->
				<xsl:if test="contains(@valueURI, 'pleiades.stoa.org')">
					<field name="pleiades_uri" update="set">
						<xsl:value-of select="@valueURI"/>
					</field>
				</xsl:if>
				<xsl:if test="contains(@valueURI, 'nomisma.org')">
					<xsl:variable name="href" select="@valueURI"/>
					
					<xsl:for-each select="$rdf/*[@rdf:about=$href]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
						<field name="pleiades_uri" update="set">
							<xsl:value-of select="@rdf:resource"/>
						</field>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
		</doc>
	</xsl:template>
</xsl:stylesheet>
