<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:nmo="http://nomisma.org/ontology#" version="2.0"
	exclude-result-prefixes="#all">

	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nmo="http://nomisma.org/ontology#">

			<xsl:variable name="id-param">
				<xsl:for-each
					select="distinct-values(descendant::tei:ref[contains(@target, 'nomisma.org')]/@target|descendant::tei:idno[@type='URI'][contains(., 'nomisma.org')])">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url"
				select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>
	
	<!-- unique persons and places -->
	<xsl:variable name="entities" as="element()*">
		<entities xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<xsl:copy-of select="//tei:particDesc/tei:listPerson/*|//tei:settingDesc/tei:listPlace/*"/>
		</entities>
	</xsl:variable>

	<xsl:variable name="docId" select="/tei:TEI/@xml:id"/>
	<xsl:variable name="timestamp"
		select="if (contains(string(current-dateTime()), 'Z')) then current-dateTime() else concat(string(current-dateTime()), 'Z')"/>


	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="tei:TEI"/>
		</add>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<doc>
			<field name="id">
				<xsl:value-of select="$docId"/>
			</field>
			<field name="primary">true</field>
			<field name="timestamp">
				<xsl:value-of select="$timestamp"/>
			</field>
			<field name="genre_facet">e-books</field>
			<field name="genre_uri">http://vocab.getty.edu/aat/300265554</field>

			<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
			<xsl:apply-templates select="tei:teiHeader/tei:profileDesc"/>
			
			<!-- cover images, if applicable -->
			<xsl:apply-templates select="descendant::tei:graphic[@url][1]"/>

			<!-- fulltext -->
			<field name="text">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</doc>

		<!-- index docs for individual components -->
		<xsl:apply-templates select="descendant::tei:div1[@xml:id]"/>
	</xsl:template>

	<!-- header metadata -->
	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt|tei:seriesStmt|tei:publicationStmt"/>
	</xsl:template>

	<!-- get names for facets -->
	<xsl:template match="tei:profileDesc">
		<xsl:for-each select="descendant::*[starts-with(local-name(), 'list')]/*">
			<xsl:variable name="field"
				select="if (parent::node()/local-name()='listPerson' or parent::node()/local-name()='listOrg') then 'name' else 'geographic'"/>

			<field name="{$field}_facet">
				<xsl:value-of select="*[contains(local-name(), 'Name')]"/>
			</field>
			<field name="{$field}_uri">
				<xsl:value-of select="tei:idno[@type='URI']"/>
			</field>

			<xsl:if test="contains(tei:idno[@type='URI'], 'pleiades.stoa.org')">
				<field name="pleiades_uri">
					<xsl:value-of select="tei:idno[@type='URI']"/>
				</field>
			</xsl:if>
			<xsl:if test="contains(tei:idno[@type='URI'], 'nomisma.org')">
				<xsl:variable name="href" select="tei:idno[@type='URI']"/>

				<xsl:for-each
					select="$rdf//*[@rdf:about=$href]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
					<field name="pleiades_uri">
						<xsl:value-of select="@rdf:resource"/>
					</field>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<field name="title">
			<xsl:value-of select="tei:title"/>
		</field>
		<xsl:if test="tei:author">
			<field name="author">
				<xsl:value-of select="string-join(tei:author/tei:name, ', ')"/>
			</field>
		</xsl:if>
		<xsl:if test="tei:editor">
			<field name="editor">
				<xsl:value-of select="string-join(tei:editor/tei:name, ', ')"/>
			</field>
		</xsl:if>
		
		<xsl:for-each select="tei:author|tei:editor">
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

	<xsl:template match="tei:seriesStmt">
		<field name="series_facet">
			<xsl:value-of select="tei:title"/>
		</field>
		<xsl:if test="tei:idno[@type='URI']">
			<field name="series_uri">
				<xsl:value-of select="tei:idno[@type='URI']"/>
			</field>
		</xsl:if>
		
		<xsl:apply-templates select="tei:biblScope"/>
	</xsl:template>
	
	<xsl:template match="tei:biblScope">
		<field name="{@unit}">
			<xsl:value-of select="."/>
		</field>
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
	
	<!-- images -->
	<xsl:template match="tei:graphic">		
		<field name="thumbnail_image">
			<xsl:value-of select="concat('media/', $docId, '/thumbnail/', @url)"/>
		</field>
		<field name="reference_image">
			<xsl:value-of select="concat('media/', $docId, '/reference/', @url)"/>
		</field>
	</xsl:template>

	<xsl:template match="tei:*[starts-with(local-name(), 'div')]">
		<xsl:variable name="div_id" select="@xml:id"/>
		<doc>
			<field name="id">
				<xsl:value-of select="concat($docId, '#', @xml:id)"/>
			</field>
			<field name="primary">false</field>
			<field name="isPartOf">
				<xsl:choose>
					<xsl:when test="parent::*[starts-with(local-name(), 'div')]">
						<xsl:value-of select="concat('#', parent::node()/@xml:id)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$docId"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="timestamp">
				<xsl:value-of select="$timestamp"/>
			</field>
			<field name="title">
				<xsl:value-of select="if (tei:head) then normalize-space(tei:head) else @type"/>
			</field>
			<xsl:choose>
				<xsl:when test="@type='chapter'">
					<field name="genre_uri">http://vocab.getty.edu/aat/300311699</field>
				</xsl:when>
				<xsl:when test="@type='section'">
					<field name="genre_uri">http://vocab.getty.edu/aat/300379391</field>
				</xsl:when>
			</xsl:choose>
			
			<!-- pleiades URIs -->
			<xsl:for-each select="distinct-values(descendant::tei:ref[matches(@target, 'https?://')][ancestor::*[starts-with(local-name(), 'div')][1][@xml:id=$div_id]]/@target|descendant::tei:name[@corresp][ancestor::*[starts-with(local-name(), 'div')][1][@xml:id=$div_id]]/@corresp)">
				<xsl:variable name="val" select="."/>
				<xsl:variable name="uri" select="if (matches($val, 'https?://')) then $val else $entities//*[@xml:id = substring-after($val, '#')]/tei:idno[@type='URI']"/>
				
				<!-- only create annotations for corresps that link to valid URIs -->
				<xsl:choose>
					<xsl:when test="contains($uri, 'pleiades.stoa.org')">
						<field name="pleiades_uri"><xsl:value-of select="$uri"/></field>
					</xsl:when>
					<xsl:when test="contains($uri, 'nomisma.org')">
						<xsl:for-each
							select="$rdf//*[@rdf:about=$uri]/skos:closeMatch[contains(@rdf:resource, 'pleiades.stoa.org')]">
							<field name="pleiades_uri">
								<xsl:value-of select="@rdf:resource"/>
							</field>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>		
			</xsl:for-each>
		</doc>
		
		<xsl:apply-templates select="*[starts-with(local-name(), 'div')][@xml:id]"/>
	</xsl:template>
</xsl:stylesheet>
