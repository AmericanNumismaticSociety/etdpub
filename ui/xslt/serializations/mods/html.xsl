<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="//mods:recordIdentifier"/>

	<!-- language normalization -->
	<xsl:variable name="languages" as="node()*">
		<xsl:copy-of select="document('oxf:/apps/etdpub/xforms/instances/languages.xml')/*"/>
	</xsl:variable>

	<xsl:variable name="namespaces" as="node()*">
		<namespaces>
			<namespace prefix="bio">http://purl.org/vocab/bio/0.1/</namespace>
			<namespace prefix="dcterms">http://purl.org/dc/terms/</namespace>
			<namespace prefix="foaf">http://xmlns.com/foaf/0.1/</namespace>
			<namespace prefix="geo">http://www.w3.org/2003/01/geo/wgs84_pos#</namespace>
			<namespace prefix="org">http://www.w3.org/ns/org#</namespace>
			<namespace prefix="owl">http://www.w3.org/2002/07/owl#</namespace>
			<namespace prefix="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</namespace>
			<namespace prefix="skos">http://www.w3.org/2004/02/skos/core#</namespace>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/mods:modsCollection/mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<html lang="en">
			<!-- dynamically generate prefix attribute -->
			<xsl:attribute name="prefix">
				<xsl:for-each select="$namespaces//namespace">
					<xsl:value-of select="@prefix"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:attribute>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}ui/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$url}ui/css/{//config/style}.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container content" itemscope="" itemtype="http://schema.org/ScholarlyArticle">
			<div class="row">
				<div class="col-md-12">
					<h2 itemprop="name">
						<xsl:value-of select="mods:titleInfo/mods:title"/>
					</h2>
				</div>
				<div class="col-md-9">
					<dl class="dl-horizontal">
						<xsl:for-each select="mods:name">
							<dt>Author</dt>
							<dd itemprop="author">
								<xsl:value-of select="mods:namePart"/>
							</dd>
						</xsl:for-each>						
						<dt>Date</dt>
						<dd itemprop="dateCreated">
							<xsl:value-of select="mods:originInfo/mods:dateCreated"/>
						</dd>
						<dt>Publisher</dt>
						<dd itemprop="publisher">
							<xsl:value-of select="mods:originInfo/mods:publisher"/>
						</dd>
						<xsl:for-each select="mods:language">
							<xsl:variable name="lang" select="mods:languageTerm"/>

							<dt>Language</dt>
							<dd>
								<xsl:value-of select="$languages/language[@value=$lang]"/>
							</dd>
						</xsl:for-each>
						<dt>Abstract</dt>
						<dd itemprop="about">
							<xsl:value-of select="mods:abstract"/>
						</dd>
					</dl>
					<xsl:if test="count(mods:subject) &gt; 0">
						<xsl:variable name="subjects" as="node()">
							<subjects>
								<xsl:copy-of select="mods:subject"/>
							</subjects>
						</xsl:variable>

						<h4>Subjects</h4>
						<xsl:for-each select="distinct-values(mods:subject/*/local-name())">
							<xsl:variable name="name" select="."/>
							<h5>
								<xsl:value-of select="etdpub:normalize_fields(.)"/>
							</h5>
							<ul>
								<xsl:apply-templates select="$subjects/mods:subject/*[local-name()=$name]">
									<xsl:sort select="local-name()"/>
									<xsl:sort select="text()"/>
								</xsl:apply-templates>
							</ul>
						</xsl:for-each>
					</xsl:if>
				</div>
				<div class="col-md-3">
					<div class="highlight">
						<xsl:variable name="href" select="if (matches(mods:location/mods:url, '^https?://')) then mods:location/mods:url else concat($display_path, mods:location/mods:url)"/>
						
						<h4>
							<a href="{$href}" itemprop="url">
								<span class="glyphicon glyphicon-download-alt"/>
								<xsl:text>Download</xsl:text>
								<xsl:choose>
									<xsl:when test="mods:physicalDescription/mods:internetMediaType='application/pdf'">
										<img src="{$display_path}ui/images/adobe.png" alt="PDF" class="doc-icon"/>
									</xsl:when>
									<xsl:when test="contains(mods:physicalDescription/mods:internetMediaType, 'word')">
										<img src="{$display_path}ui/images/word.png" alt="Microsoft Word" class="doc-icon"/>
									</xsl:when>
									<xsl:when test="contains(mods:physicalDescription/mods:internetMediaType, 'oasis')">
										<img src="{$display_path}ui/images/writer.png" alt="LibreOffice Writer" class="doc-icon"/>
									</xsl:when>
								</xsl:choose>
							</a>
						</h4>
						<xsl:variable name="license" select="mods:accessCondition/@xlink:href"/>
						<a href="{$license}" itemprop="licence">
							<xsl:choose>
								<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by/')">
									<img src="http://i.creativecommons.org/l/by/3.0/88x31.png" alt="CC BY" title="CC BY"/>
								</xsl:when>
								<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nd/')">
									<img src="http://i.creativecommons.org/l/by-nd/3.0/88x31.png" alt="CC BY-ND" title="CC BY-ND"/>
								</xsl:when>
								<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nc-sa/')">
									<img src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" alt="CC BY-NC-SA" title="CC BY-NC-SA"/>
								</xsl:when>
								<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-sa/')">
									<img src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" alt="CC BY-SA" title="CC BY-SA"/>
								</xsl:when>
								<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nc/')">
									<img src="http://i.creativecommons.org/l/by-nc/3.0/88x31.png" alt="CC BY-NC" title="CC BY-NC"/>
								</xsl:when>
								<xsl:when test="contains($license, 'http://creativecommons.org/licenses/by-nc-nd/')">
									<img src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" alt="CC BY-NC-ND" title="CC BY-NC-ND"/>
								</xsl:when>
							</xsl:choose>
						</a>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="mods:subject/*">
		<li>
			<xsl:if test="local-name()='genre'">
				<xsl:attribute name="itemprop">genre</xsl:attribute>
			</xsl:if>
			<a href="{$display_path}results?q={local-name()}_facet:&#x022;{.}&#x022;">
				<xsl:value-of select="."/>
			</a>
			
			<xsl:if test="string(@valueURI)">
				<a href="{@valueURI}" title="{@valueURI}" class="external-link">
					<img src="{$display_path}ui/images/external.png" alt="External Link"/>
				</a>
			</xsl:if>
		</li>
	</xsl:template>
</xsl:stylesheet>
