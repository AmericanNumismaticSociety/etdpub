<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path" select="if (/content/config/ark/@enabled='true') then '../../' else '../'"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="//mods:recordIdentifier"/>
	<xsl:variable name="genre" select="//mods:mods/mods:genre"/>

	<!-- language normalization -->
	<xsl:variable name="languages" as="node()*">
		<xsl:copy-of select="document('oxf:/apps/etdpub/xforms/instances/languages.xml')/*"/>
	</xsl:variable>
	<!-- load available templates -->
	<xsl:variable name="templates" as="node()*">
		<xsl:copy-of select="document('oxf:/apps/etdpub/xforms/instances/templates.xml')/*"/>
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
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$url}ui/css/{//config/style}.css"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container content" itemscope="" itemtype="{$templates//template[.=$genre]/@itemtype}">
			<div class="row">
				<div class="col-md-12">
					<h2 itemprop="name">
						<xsl:value-of select="mods:titleInfo/mods:title"/>
					</h2>
					<xsl:if test="mods:titleInfo/mods:subTitle">
						<h3>
							<xsl:value-of select="mods:titleInfo/mods:subTitle"/>
						</h3>
					</xsl:if>
				</div>
				<div class="col-md-9">
					<!--document metadata -->
					<dl class="dl-horizontal">
						<xsl:for-each select="mods:name">
							<dt>
								<xsl:value-of select="mods:role/mods:roleTerm[@type='text']"/>
							</dt>
							<dd>
								<xsl:value-of select="mods:namePart"/>
								<xsl:if test="@valueURI">
									<a href="{@valueURI}" title="{@valueURI}" class="external-link" itemprop="author">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</xsl:if>
							</dd>
							<xsl:apply-templates select="mods:nameIdentifier[@type='orcid']"/>
							<xsl:if test="mods:affiliation">
								<dt>University</dt>
								<dd itemprop="publisher">
									<xsl:value-of select="mods:affiliation"/>
								</dd>
							</xsl:if>
						</xsl:for-each>
						<xsl:if test="mods:originInfo/mods:dateIssued">
							<dt>Date</dt>
							<dd itemprop="dateCreated">
								<xsl:value-of select="mods:originInfo/mods:dateIssued"/>
							</dd>
						</xsl:if>
						<xsl:if test="mods:originInfo/mods:publisher">
							<dt>Publisher</dt>
							<dd itemprop="publisher">
								<xsl:value-of select="mods:originInfo/mods:publisher"/>
							</dd>
						</xsl:if>
						
						<xsl:apply-templates select="mods:identifier[@type='DOI']"/>
						
						<!-- parent journal -->
						<xsl:apply-templates select="mods:relatedItem[@type='host']"/>
						
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

					<!-- subject terms -->
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
									<xsl:sort select="if ($name='name') then mods:namePart else text()"/>
								</xsl:apply-templates>
							</ul>
						</xsl:for-each>
					</xsl:if>
				</div>
				<div class="col-md-3">
					<div class="highlight">
						<xsl:variable name="href" select="if (matches(mods:location/mods:url, '^https?://')) then mods:location/mods:url else concat($display_path, mods:location/mods:url)"/>
						<xsl:variable name="license" select="mods:accessCondition/@xlink:href"/>

						<div>
							<h3>Download</h3>
							<h4>
								<a href="{$href}" itemprop="url">
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
						</div>
						<div>
							<h3>License</h3>
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
						<div>
							<h3>Export</h3>
							<ul class="list-inline">
								<li>
									<a href="{$id}.xml" title="MODS/XML">MODS/XML</a>
								</li>
								<li>
									<a href="{$id}.rdf" title="RDF/XML">RDF/XML</a>
								</li>
							</ul>
							
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="mods:relatedItem[@type='host']">
		<dt>Citation</dt>
		<dd>
			<i>
				<a href="{mods:identifier}">
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</a>
			</i>
			<xsl:if test="mods:part/mods:detail[@type='volume'] and mods:part/mods:detail[@type='issue']">
				<xsl:text> </xsl:text>
				<xsl:value-of select="mods:part/mods:detail[@type='volume']/mods:number"/>
				<xsl:text>, no. </xsl:text>
				<xsl:value-of select="mods:part/mods:detail[@type='issue']/mods:number"/>
			</xsl:if>
			<xsl:text> (</xsl:text>
			<xsl:value-of select="mods:part/mods:date"/>
			<xsl:text>): </xsl:text>
			<xsl:choose>
				<xsl:when test="mods:part/mods:extent[@unit='pages']/mods:start = mods:part/mods:extent[@unit='pages']/mods:end">
					<xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:start"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:start"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:end"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>.</xsl:text>

		</dd>
	</xsl:template>
	
	<xsl:template match="mods:nameIdentifier[@type='orcid']">
		<dt>ORCID</dt>
		<dd>
			<a href="{.}" itemprop="author">
				<xsl:value-of select="."/>
			</a>
		</dd>
	</xsl:template>
	
	<xsl:template match="mods:identifier[@type='DOI']">
		<dt>DOI</dt>
		<dd>
			<a href="http://dx.doi.org/{.}" itemprop="sameAs">
				<xsl:value-of select="."/>
			</a>
		</dd>
	</xsl:template>

	<xsl:template match="mods:subject/*">
		<xsl:variable name="val" select="if (local-name()='name') then normalize-space(mods:namePart) else normalize-space(.)"/>

		<li>
			<a href="{$display_path}results?q={local-name()}_facet:&#x022;{$val}&#x022;">
				<xsl:value-of select="$val"/>
			</a>

			<xsl:if test="string(@valueURI)">
				<a href="{@valueURI}" title="{@valueURI}" class="external-link">
					<xsl:choose>
						<xsl:when test="local-name()='genre'">
							<xsl:attribute name="itemprop">genre</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="itemprop">about</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</xsl:if>
		</li>
	</xsl:template>
</xsl:stylesheet>
