<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0"
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
			<xsl:apply-templates select="tei:TEI"/>
		</add>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<doc>
			<field name="id">
				<xsl:value-of select="@xml:id"/>
			</field>
			<field name="timestamp">
				<xsl:value-of select="if (contains(string(current-dateTime()), 'Z')) then current-dateTime() else concat(string(current-dateTime()), 'Z')"/>
			</field>

			<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
			<xsl:apply-templates select="tei:teiHeader/tei:profileDesc"/>
			<xsl:apply-templates select="tei:text/tei:body"/>			
			
			<!-- fulltext -->
			<field name="text">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</doc>
	</xsl:template>

	<!-- header metadata -->
	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt|tei:publicationStmt"/>
	</xsl:template>
	
	<!-- get names for facets -->
	<xsl:template match="tei:profileDesc">
		<xsl:for-each select="descendant::*[starts-with(local-name(), 'list')]/*">
			<xsl:variable name="field" select="if (parent::node()/local-name()='listPerson' or parent::node()/local-name()='listOrg') then 'name' else 'place'"/>
			
			<field name="{$field}_facet">
				<xsl:value-of select="*[contains(local-name(), 'Name')]"/>
			</field>
			<field name="{$field}_uri">
				<xsl:value-of select="tei:idno[@type='URI']"/>
			</field>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<field name="title">
			<xsl:value-of select="tei:title"/>
		</field>
		<field name="author">
			<xsl:value-of select="string-join(tei:author/tei:name, ', ')"/>
		</field>
		<xsl:for-each select="tei:author">
			<field name="creator_facet">
				<xsl:value-of select="tei:name"/>
			</field>
			<xsl:if test="tei:idno[@type='URI']">
				<field name="creator_uri">
					<xsl:value-of select="tei:idno[@type='URI']"/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<xsl:if test="tei:date">
			<field name="date">
				<xsl:value-of select="tei:date"/>
			</field>
		</xsl:if>
		<xsl:for-each select="tei:publisher">
			<field name="publisher_facet">
				<xsl:value-of select="tei:name"/>
			</field>
			<xsl:if test="tei:idno[@type='URI']">
				<field name="publisher_uri">
					<xsl:value-of select="tei:idno[@type='URI']"/>
				</field>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- placeholder for facets, etc -->
	<xsl:template match="tei:body"/>
</xsl:stylesheet>
