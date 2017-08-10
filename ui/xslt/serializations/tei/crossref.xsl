<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.crossref.org/schema/4.4.0" xmlns:digest="org.apache.commons.codec.digest.DigestUtils"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" version="2.0" exclude-result-prefixes="#all">
	<xsl:include href="../../functions.xsl"/>

	<!-- URI variables -->
	<xsl:variable name="id" select="/tei:TEI/@xml:id"/>
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


	<xsl:template match="/tei:TEI">
		<doi_batch version="4.4.0" xmlns="http://www.crossref.org/schema/4.4.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.crossref.org/schema/4.4.0
			http://www.crossref.org/schemas/crossref4.4.0.xsd">

			<!-- head -->
			<xsl:apply-templates select="doc('input:config-xml')/config/crossref"/>

			<!-- body -->
			<body>
				<!-- evaluate whether it is a book of chapters or some other type of book: a book of chapters should have an editor and not author in the teiHeader -->
				<xsl:choose>
					<!--<xsl:when
						test="descendant::*[starts-with(local-name(), 'div')][@type = 'chapter']/tei:byline/descendant-or-self::*[(local-name() = 'name' and @type = 'pname') or local-name() = 'persName']"> </xsl:when>-->
					<xsl:when test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
						<xsl:apply-templates select="tei:teiHeader">
							<xsl:with-param name="type">edited_book</xsl:with-param>
						</xsl:apply-templates>

						<!-- apply-templates for each chapter in the body that has a byline -->
						<xsl:apply-templates select="tei:text/tei:body/tei:div1[tei:byline]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="tei:teiHeader">
							<xsl:with-param name="type">monograph</xsl:with-param>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
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

	<xsl:template match="tei:teiHeader">
		<xsl:param name="type"/>

		<book book_type="{$type}">
			<xsl:apply-templates select="tei:fileDesc"/>
		</book>


	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:choose>
			<xsl:when test="tei:seriesStmt">
				<book_set_metadata language="en">
					<xsl:apply-templates select="tei:seriesStmt"/>
					<xsl:call-template name="book_metadata"/>
				</book_set_metadata>
			</xsl:when>
			<xsl:otherwise>
				<book_metadata language="en">
					<xsl:call-template name="book_metadata"/>
				</book_metadata>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="book_metadata">
		<xsl:apply-templates select="tei:titleStmt | tei:publicationStmt"/>
		<doi_data>
			<doi>
				<xsl:value-of select="concat(doc('input:config-xml')/config/crossref/doi_prefix, '/', $id)"/>
			</doi>
			<resource>
				<xsl:value-of select="concat($uri_space, $id)"/>
			</resource>
		</doi_data>
	</xsl:template>

	<xsl:template match="tei:seriesStmt">
		<set_metadata>
			<titles>
				<title>
					<xsl:value-of select="tei:title"/>
				</title>
			</titles>
		</set_metadata>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<publication_date>
			<year>
				<xsl:choose>
					<xsl:when test="tei:date castable as xs:gYear">
						<xsl:value-of select="tei:date"/>
					</xsl:when>
					<xsl:when test="matches(tei:date, '1|2[0-9]{3}')">
						<xsl:value-of select="normalize-space(substring-after(tei:date, ','))"/>
					</xsl:when>
					<xsl:otherwise> </xsl:otherwise>
				</xsl:choose>
			</year>
		</publication_date>
		<noisbn reason="archive_volume"/>
		<publisher>
			<publisher_name>
				<xsl:value-of select="tei:publisher/tei:name"/>
			</publisher_name>
		</publisher>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<xsl:if test="tei:author or tei:editor">
			<contributors>
				<xsl:apply-templates select="tei:author|tei:editor"/>
			</contributors>
		</xsl:if>
		<titles>
			<title>
				<xsl:value-of select="tei:title"/>
			</title>
			<xsl:if test="tei:subtitle">
				<subtitle>
					<xsl:value-of select="tei:subtitle"/>
				</subtitle>
			</xsl:if>
		</titles>
		<!--<xsl:if test="parent::node()/tei:seriesStmt/tei:biblScope[@unit='issue']">
			<volume>
				<xsl:value-of select="parent::node()/tei:seriesStmt/tei:biblScope[@unit='issue']"/>
			</volume>
		</xsl:if>-->
	</xsl:template>

	<xsl:template match="tei:author|tei:editor">
		<person_name sequence="{if (position() = 1) then 'first' else 'additional'}" contributor_role="{local-name()}">
			<xsl:call-template name="etdpub:parse_name">
				<xsl:with-param name="name" select="tei:name"/>
			</xsl:call-template>

			<!-- ORCID if available (regex from Crossref XSD) -->
			<xsl:if test="tei:idno[@type='URI'][matches(., 'https?://orcid.org/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[X0-9]{1}')]">
				<ORCID>
					<xsl:value-of select="tei:idno[@type='URI'][matches(., 'https?://orcid.org/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[X0-9]{1}')]"/>
				</ORCID>
			</xsl:if>
		</person_name>
	</xsl:template>

	<!-- process chapters with bylines in edited volumes -->
	<xsl:template match="tei:div1">
		<content_item component_type="chapter">

			<xsl:if test="tei:byline[descendant::tei:name[@type='pname'][@corresp] or descendant::tei:persName[@corresp]]">
				<contributors>
					<xsl:apply-templates select="tei:byline/descendant::tei:name[@type='pname'][@corresp]|tei:byline/descendant::tei:persName[@corresp]"/>
				</contributors>
			</xsl:if>
			<titles>
				<title>
					<xsl:value-of select="tei:head"/>
				</title>
			</titles>
		</content_item>
	</xsl:template>

	<xsl:template match="tei:name[@type='pname']|tei:persName">
		<xsl:variable name="id" select="substring-after(@corresp, '#')"/>
		<xsl:variable name="entity" as="element()*">
			<xsl:copy-of select="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc//*[starts-with(local-name(), 'list')]/*[@xml:id=$id]"/>
		</xsl:variable>
		<xsl:variable name="name" select="$entity//tei:*[contains(local-name(), 'Name')]"/>

		<person_name sequence="{if (position() = 1) then 'first' else 'additional'}" contributor_role="author">
			<xsl:call-template name="parse_name">
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>
		</person_name>
	</xsl:template>
</xsl:stylesheet>
