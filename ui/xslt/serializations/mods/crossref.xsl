<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns="http://www.crossref.org/schema/4.4.0" xmlns:digest="org.apache.commons.codec.digest.DigestUtils"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" xmlns:jats="http://www.ncbi.nlm.nih.gov/JATS1" version="2.0" exclude-result-prefixes="xsl xs xlink mods digest etdpub">
	<xsl:include href="../../functions.xsl"/>

	<!-- URI variables -->
	<xsl:variable name="id" select="//mods:mods/mods:recordInfo/mods:recordIdentifier"/>
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="doc('input:config-xml')/config/ark/@enabled = 'true'">
				<xsl:value-of select="concat(doc('input:config-xml')/config/url, 'ark:/', doc('input:config-xml')/config/ark/naan, '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(doc('input:config-xml')/config/url, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="genre" select="//mods:mods/mods:genre/@valueURI"/>

	<xsl:template match="/">
		<doi_batch version="4.4.0" xmlns="http://www.crossref.org/schema/4.4.0" xmlns:jats="http://www.ncbi.nlm.nih.gov/JATS1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.crossref.org/schema/4.4.0
		http://www.crossref.org/schemas/crossref4.4.0.xsd">

			<!-- head -->
			<xsl:apply-templates select="doc('input:config-xml')/config/crossref"/>

			<!--body -->
			<body>
				<xsl:apply-templates select="//mods:mods"/>
			</body>
		</doi_batch>
	</xsl:template>

	<!-- Crossref header, derived from config metadata -->
	<xsl:template match="crossref">
		<head>
			<!-- batch ID is the document URI encrypted into md5 hash, will be unique -->
			<doi_batch_id>
				<xsl:value-of select="digest:md5Hex(concat($uri_space, $id))"/>
			</doi_batch_id>
			<!-- timestamp is seconds from 1970 (rounded up), from https://stackoverflow.com/questions/3467771/convert-datetime-to-unix-epoch-in-xslt -->
			<timestamp>
				<xsl:value-of select="ceiling(( current-dateTime() - xs:dateTime('1970-01-01T00:00:00') )
					div
					xs:dayTimeDuration('PT1S'))"/>
			</timestamp>
			<depositor>
				<depositor_name>
					<xsl:value-of select="depositor_name"/>
				</depositor_name>
				<email_address>
					<xsl:value-of select="depositor_email"/>
				</email_address>
			</depositor>
			<registrant>
				<xsl:value-of select="parent::node()/publisher"/>
			</registrant>
		</head>
	</xsl:template>

	<xsl:template match="mods:mods">
		<xsl:choose>
			<!-- dissertation -->
			<xsl:when test="$genre='http://vocab.getty.edu/aat/300028029'">
				<dissertation>
					<xsl:call-template name="body_metadata"/>
				</dissertation>
			</xsl:when>
			<!-- auction catalog: monograph -->
			<xsl:when test="$genre='http://vocab.getty.edu/aat/300026068'">
				<book book_type="other">
					<book_metadata>
						<xsl:call-template name="body_metadata"/>
					</book_metadata>
				</book>
			</xsl:when>
		</xsl:choose>


	</xsl:template>

	<xsl:template name="body_metadata">
		<xsl:choose>
			<!-- dissertation: single author -->
			<xsl:when test="$genre='http://vocab.getty.edu/aat/300028029'">
				<xsl:apply-templates select="mods:name"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise, a book must have contributors -->
				<xsl:if test="mods:name">
					<contributors>
						<xsl:apply-templates select="mods:name"/>
					</contributors>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<!--<xsl:apply-templates select="mods:abstract"/>-->
		<xsl:apply-templates select="mods:titleInfo"/>
		<xsl:apply-templates select="mods:originInfo"/>

		<xsl:apply-templates select="mods:name/mods:affiliation"/>

		<doi_data>
			<doi>
				<xsl:value-of select="concat(doc('input:config-xml')/config/crossref/doi_prefix, '/', $id)"/>
			</doi>
			<resource>
				<xsl:value-of select="concat($uri_space, $id)"/>
			</resource>
		</doi_data>
	</xsl:template>

	<xsl:template match="mods:name">
		<person_name sequence="{if (position() = 1) then 'first' else 'additional'}" contributor_role="{lower-case(mods:role/mods:roleTerm[@type='text'])}">
			<xsl:call-template name="etdpub:parse_name">
				<xsl:with-param name="name" select="mods:namePart"/>
			</xsl:call-template>

			<!-- ORCID if available (regex from Crossref XSD) -->
			<xsl:if test="matches(mods:nameIdentifier[@type='orcid'], 'https?://orcid.org/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[X0-9]{1}')">
				<ORCID>
					<xsl:value-of select="mods:nameIdentifier[@type='orcid']"/>
				</ORCID>
			</xsl:if>
		</person_name>
	</xsl:template>

	<xsl:template match="mods:originInfo">
		<xsl:apply-templates select="mods:dateIssued"/>
		<xsl:apply-templates select="mods:publisher"/>
	</xsl:template>

	<xsl:template match="mods:dateIssued">
		<xsl:choose>
			<!-- use approval_date for dissertation, publication_date for other genres -->
			<xsl:when test="$genre = 'http://vocab.getty.edu/aat/300028029'">
				<approval_date>
					<xsl:call-template name="year"/>
				</approval_date>
			</xsl:when>
			<xsl:otherwise>
				<publication_date>
					<xsl:call-template name="year"/>
				</publication_date>
				<noisbn reason="archive_volume"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="year">
		<year>
			<xsl:choose>
				<xsl:when test=". castable as xs:gYear">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="matches(., '1|2[0-9]{3}')">
					<xsl:value-of select="normalize-space(substring-after(., ','))"/>
				</xsl:when>
				<xsl:otherwise> </xsl:otherwise>
			</xsl:choose>
		</year>
	</xsl:template>

	<xsl:template match="mods:publisher">
		<publisher>
			<publisher_name>
				<xsl:value-of select="."/>
			</publisher_name>
		</publisher>
	</xsl:template>

	<xsl:template match="mods:titleInfo">
		<titles>
			<title>
				<xsl:value-of select="mods:title"/>
			</title>
			<xsl:if test="mods:subTitle">
				<subtitle>
					<xsl:value-of select="mods:subTitle"/>
				</subtitle>
			</xsl:if>
		</titles>
	</xsl:template>

	<xsl:template match="mods:affiliation">
		<institution>
			<institution_name>
				<xsl:value-of select="."/>
			</institution_name>
		</institution>
	</xsl:template>

	<xsl:template match="mods:abstract">
		<jats:abstract>
			<jats:p>
				<xsl:value-of select="."/>
			</jats:p>
		</jats:abstract>
	</xsl:template>
</xsl:stylesheet>
