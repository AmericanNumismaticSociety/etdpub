<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#" xmlns:schema="http://schema.org/"
	xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:oa="http://www.w3.org/ns/oa#" version="2.0"
	exclude-result-prefixes="xsl xs xlink tei">

	<!-- URI variables -->
	<xsl:variable name="id" select="//tei:TEI/@xml:id"/>
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="/content/config/ark/@enabled = 'true'">
				<xsl:value-of select="concat(/content/config/url, 'ark:/', /content/config/ark/naan, '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(/content/config/url, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- unique persons and places -->
	<xsl:variable name="entities" as="element()*">
		<entities xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<xsl:copy-of select="//tei:particDesc/tei:listPerson/* | //tei:particDesc/tei:listOrg/* | //tei:settingDesc/tei:listPlace/*"/>
		</entities>
	</xsl:variable>

	<xsl:template match="/">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:oa="http://www.w3.org/ns/oa#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
			xmlns:org="http://www.w3.org/ns/org#" xmlns:schema="http://schema.org/" xmlns:dcmitype="http://purl.org/dc/dcmitype/"
			xmlns:edm="http://www.europeana.eu/schemas/edm/">
			<xsl:apply-templates select="//tei:TEI"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<schema:Book rdf:about="{concat($uri_space, $id)}">
			<!-- bibliographic metadata -->
			<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>

			<!-- related bibliographic entities, DOI -->
			<xsl:apply-templates select="tei:teiHeader/tei:sourceDesc"/>

			<!-- add in links to the PDF and the EPUB -->
			<edm:isShownBy rdf:resource="{concat($uri_space, $id)}/pdf"/>
			<edm:isShownBy rdf:resource="{concat($uri_space, $id)}.epub"/>
			
			<dcterms:type rdf:resource="http://vocab.getty.edu/aat/300060417"/>

			<!-- insert images, if applicable -->
			<xsl:apply-templates select="descendant::tei:graphic[@url][1]"/>

			<xsl:apply-templates select="descendant::tei:keywords"/>
		</schema:Book>

		<edm:WebResource rdf:about="{concat($uri_space, $id)}/pdf">
			<dcterms:format>application/pdf</dcterms:format>
		</edm:WebResource>

		<edm:WebResource rdf:about="{concat($uri_space, $id)}.epub">
			<dcterms:format>application/epub+zip</dcterms:format>
		</edm:WebResource>

		<!-- apply templates for each div -->
		<xsl:apply-templates select="descendant::tei:div1[@xml:id]" mode="structure"/>

		<!-- create annotations for each link within the tei:text -->
		<!--<xsl:apply-templates select="descendant::tei:text/descendant::tei:ref[@target]"/>-->
		<xsl:apply-templates select="descendant::tei:div1[@xml:id]" mode="annotation"/>
	</xsl:template>

	<!-- header metadata about the whole document -->
	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt | tei:publicationStmt | tei:seriesStmt | tei:sourceDesc"/>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<dcterms:title>
			<xsl:value-of select="tei:title"/>
		</dcterms:title>
		<xsl:for-each select="tei:author">
			<dcterms:creator>
				<xsl:choose>
					<xsl:when test="tei:idno[@type = 'URI']">
						<xsl:attribute name="rdf:resource" select="normalize-space(tei:idno[@type = 'URI'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="tei:name"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcterms:creator>
		</xsl:for-each>
		<xsl:for-each select="tei:editor">
			<dcterms:contributor>
				<xsl:choose>
					<xsl:when test="tei:idno[@type = 'URI']">
						<xsl:attribute name="rdf:resource" select="normalize-space(tei:idno[@type = 'URI'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="tei:name"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcterms:contributor>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<xsl:apply-templates select="tei:date"/>
		<xsl:for-each select="tei:publisher">
			<dcterms:publisher>
				<xsl:choose>
					<xsl:when test="tei:idno[@type = 'URI']">
						<xsl:attribute name="rdf:resource" select="normalize-space(tei:idno[@type = 'URI'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="tei:name"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcterms:publisher>
		</xsl:for-each>
		<xsl:apply-templates select="tei:idno[@type = 'DOI']"/>
	</xsl:template>

	<xsl:template match="tei:seriesStmt">
		<dcterms:isPartOf>
			<xsl:choose>
				<xsl:when test="tei:idno[@type = 'URI']">
					<xsl:attribute name="rdf:resource" select="tei:idno[@type = 'URI']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="tei:title"/>
				</xsl:otherwise>
			</xsl:choose>
		</dcterms:isPartOf>
	</xsl:template>

	<xsl:template match="tei:date">
		<dcterms:date>
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
		</dcterms:date>
	</xsl:template>

	<!-- link to source bibliographic record -->
	<xsl:template match="tei:sourceDesc">
		<xsl:apply-templates select="tei:bibl[tei:idno[@type = 'URI']]"/>
	</xsl:template>

	<xsl:template match="tei:bibl[tei:idno[@type = 'URI']]">
		<xsl:variable name="href" select="tei:idno[@type = 'URI']"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'hdl.handle.net')">
				<dcterms:source rdf:resource="{$href}"/>
			</xsl:when>
			<xsl:when test="contains($href, 'worldcat.org/entity/')">
				<schema:exampleOfWork>
					<schema:CreativeWork rdf:about="{$href}">
						<xsl:for-each select="parent::node()/tei:bibl[not(contains(tei:idno, 'worldcat.org/entity/'))]">
							<schema:workExample rdf:resource="{tei:idno}"/>
						</xsl:for-each>
					</schema:CreativeWork>
				</schema:exampleOfWork>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- images -->
	<xsl:template match="tei:graphic">
		<foaf:thumbnail rdf:resource="{concat(/content/config/url, 'media/', $id, '/thumbnail/', @url)}"/>
		<foaf:depiction rdf:resource="{concat(/content/config/url, 'media/', $id, '/reference/', @url)}"/>
	</xsl:template>

	<!-- associated keywords by parsing @scheme -->
	<xsl:template match="tei:keywords">
		<xsl:apply-templates select="tei:term[@ref]"/>
	</xsl:template>

	<xsl:template match="tei:term">
		<dcterms:subject rdf:resource="{@ref}"/>
	</xsl:template>

	<xsl:template match="tei:bibl">
		<xsl:apply-templates select="tei:idno"/>
	</xsl:template>

	<xsl:template match="tei:idno">
		<dcterms:identifier>
			<xsl:value-of select="."/>
		</dcterms:identifier>
	</xsl:template>

	<!-- child sections -->
	<xsl:template match="tei:*[starts-with(local-name(), 'div')]" mode="structure">
		<xsl:variable name="parent_uri">
			<xsl:choose>
				<xsl:when test="starts-with(parent::node()/local-name(), 'div')">
					<xsl:value-of select="concat($uri_space, $id, '#', parent::node()/@xml:id)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($uri_space, $id)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="dcmitype:Text">
			<xsl:attribute name="rdf:about" select="concat($uri_space, $id, '#', @xml:id)"/>
			<dcterms:title>
				<xsl:value-of select="
						if (tei:head) then
							normalize-space(tei:head[1])
						else
							@type"/>
			</dcterms:title>
			<xsl:if test="@type = 'chapter'">
				<dcterms:type rdf:resource="http://vocab.getty.edu/aat/300311699"/>
			</xsl:if>
			<dcterms:isPartOf rdf:resource="{$parent_uri}"/>
			<dcterms:source rdf:resource="{concat($uri_space, $id)}"/>
		</xsl:element>

		<xsl:apply-templates select="*[starts-with(local-name(), 'div')]" mode="structure"/>
	</xsl:template>

	<xsl:template match="tei:*[starts-with(local-name(), 'div')]" mode="annotation">
		<xsl:variable name="div_id" select="@xml:id"/>

		<xsl:for-each
			select="distinct-values(descendant::tei:ref[matches(@target, 'https?://')][ancestor::*[starts-with(local-name(), 'div')][1][@xml:id = $div_id]]/@target | descendant::tei:*[contains(local-name(), 'Name')][@corresp][ancestor::*[starts-with(local-name(), 'div')][1][@xml:id = $div_id]]/@corresp)">
			<xsl:variable name="val" select="."/>
			<xsl:variable name="uri"
				select="
					if (matches($val, 'https?://')) then
						$val
					else
						$entities//*[@xml:id = substring-after($val, '#')]/tei:idno[@type = 'URI']"/>

			<!-- only create annotations for corresps that link to valid URIs -->
			<xsl:if test="string($uri)">
				<xsl:element name="oa:Annotation" namespace="http://www.w3.org/ns/oa#">
					<xsl:attribute name="rdf:about" select="concat($uri_space, $id, '.rdf#', $div_id, '/annotations/', format-number(position(), '0000'))"/>

					<oa:hasBody rdf:resource="{$uri}"/>
					<oa:hasTarget rdf:resource="{concat($uri_space, $id, '#', $div_id)}"/>
				</xsl:element>
			</xsl:if>
		</xsl:for-each>
		<xsl:apply-templates select="*[starts-with(local-name(), 'div')]" mode="annotation"/>
	</xsl:template>

	<!-- annotation -->
	<!--<xsl:template match="tei:ref">
		<xsl:variable name="uri" select="@target"/>
		
		<oa:Annotation rdf:about="{concat($uri_space, $id)}.rdf#{position()}">
			<oa:hasBody rdf:resource="{@target}"/>
			<oa:hasTarget rdf:resource="{concat($uri_space, $id, '#', ancestor::*[starts-with(local-name(), 'div')][1]/@xml:id)}"/>
		</oa:Annotation>
	</xsl:template>-->
</xsl:stylesheet>
