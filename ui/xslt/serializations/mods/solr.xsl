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
			<field name="title" update="set">
				<xsl:value-of select="//mods:title"/>
			</field>
			<field name="author" update="set">
				<xsl:value-of select="string-join(mods:name/mods:namePart, '; ')"/>
			</field>
			<field name="timestamp" update="set">
				<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
			</field>			
			<field name="abstract" update="add">
				<xsl:value-of select="normalize-space(mods:abstract)"/>
			</field>
			<field name="rights" update="add">
				<xsl:value-of select="mods:accessCondition/@xlink:href"/>
			</field>
			<field name="primary" update="add">true</field>
			<field name="oai_id" update="add">
				<xsl:text>oai:</xsl:text>
				<xsl:value-of select="doc('input:request')/request/server-name"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="//mods:recordIdentifier"/>
			</field>
			<xsl:if test="mods:location/mods:url">
				<field name="media_url" update="add">
					<xsl:value-of select="mods:location/mods:url"/>
				</field>
			</xsl:if>
			<xsl:if test="mods:physicalDescription/mods:internetMediaType">
				<field name="media_type" update="add">
					<xsl:value-of select="mods:physicalDescription/mods:internetMediaType"/>
				</field>
			</xsl:if>			

			<xsl:for-each select="mods:language">
				<field name="language" update="set">
					<xsl:value-of select="mods:languageTerm"/>
				</field>
			</xsl:for-each>
			
			<!-- index authors and publishers as facets -->
			<xsl:for-each select="mods:name">
				<field name="creator_facet" update="add">
					<xsl:value-of select="mods:namePart"/>
				</field>
				<xsl:if test="string(@valueURI)">
					<field name="creator_uri" update="set">
						<xsl:value-of select="@valueURI"/>
					</field>
				</xsl:if>
				<xsl:if test="mods:affiliation">
					<field name="university" update="add">
						<xsl:value-of select="mods:affiliation"/>
					</field>
				</xsl:if>
			</xsl:for-each>
			
			<xsl:apply-templates select="mods:originInfo"/>
			
			<xsl:apply-templates select="mods:relatedItem[@type='host']"/>

			<!-- subject facets -->
			<xsl:apply-templates select="mods:genre|mods:subject/*" mode="subjectTerm"/>
			
			<!-- fulltext -->
			<field name="text" update="add">
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>			
		</doc>
	</xsl:template>
	
	<xsl:template match="*" mode="subjectTerm">
		<xsl:variable name="val" select="if (local-name()='name') then normalize-space(mods:namePart) else normalize-space(.)"/>
		
		<field name="{local-name()}_facet" update="set">
			<xsl:value-of select="$val"/>
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
	</xsl:template>
	
	<!-- publication information -->
	<xsl:template match="mods:originInfo">
		<xsl:if test="mods:dateIssued">
			<field name="date" update="add">
				<xsl:value-of select="mods:dateIssued"/>
			</field>
		</xsl:if>
		
		<xsl:if test="mods:publisher">
			<field name="publisher_facet" update="add">
				<xsl:value-of select="mods:publisher"/>
			</field>			
		</xsl:if>
	</xsl:template>
	
	<!-- parent journal information -->
	<xsl:template match="mods:relatedItem[@type='host']">
		<field name="volume_id" update="add">
			<xsl:value-of select="mods:identifier"/>
		</field>
		<field name="volume_title" update="add">
			<xsl:value-of select="mods:titleInfo/mods:title"/>
		</field>
		<field name="series_facet" update="add">
			<xsl:value-of select="mods:titleInfo/mods:title"/>
		</field>
		<field name="date" update="add">
			<xsl:value-of select="mods:part/mods:date"/>
		</field>
		<xsl:if test="mods:part/mods:detail[@type='volume']">
			<field name="volume" update="add">
				<xsl:value-of select="mods:part/mods:detail[@type='volume']/mods:number"/>
			</field>
		</xsl:if>
		<xsl:if test="mods:part/mods:detail[@type='issue']">
			<field name="issue" update="add">
				<xsl:value-of select="mods:part/mods:detail[@type='issue']/mods:number"/>
			</field>
		</xsl:if>
		<field name="pages" update="add">
			<xsl:choose>
				<xsl:when test="mods:part/mods:extent[@unit='pages']/mods:start = mods:part/mods:extent[@unit='pages']/mods:end">
					<xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:start"/>
				</xsl:when>	
				<xsl:otherwise>
					<xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:start"/>
					<xsl:text> - </xsl:text>
					<xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:end"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
	</xsl:template>
</xsl:stylesheet>
