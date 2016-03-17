<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:epub="http://www.idpf.org/2007/ops" xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="html-templates.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path" select="if (/content/config/ark/@enabled='true') then '../../' else '../'"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>

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
		<xsl:apply-templates select="/content/tei:TEI"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
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
					<xsl:value-of select="//tei:titleStmt/tei:title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}ui/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/jquery.fancybox.pack.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/jquery.fancybox.css"/>
				<link rel="stylesheet" href="{$display_path}ui/css/{//config/style}.css"/>
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
		<div class="container content" itemtype="http://schema.org/Book">
			<div class="row">
				<div class="col-md-12">
					<!-- title -->
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
				</div>
			</div>
			<div class="row">
				<div class="col-md-9">
					<!-- title and bibliographic metadata -->
					<xsl:apply-templates select="tei:teiHeader"/>
				</div>
				<div class="col-md-3">
					<div class="highlight">
						<xsl:variable name="license" select="//tei:licence/@target"/>

						<xsl:if test="string($license)">
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
						</xsl:if>

						<div>
							<h3>Export</h3>
							<ul class="list-inline">
								<li>
									<a href="{$id}.xml" title="TEI">TEI</a>
								</li>
								<li>
									<a href="{$id}.rdf" title="RDF/XML">RDF/XML</a>
								</li>
								<li>
									<a href="{$id}.epub" title="EPUB" itemprop="exampleOfWork">EPUB</a>
								</li>
							</ul>

						</div>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<xsl:apply-templates select="tei:text"/>

					<!-- endnotes -->
					<xsl:if test="count(tei:text/descendant::tei:note[@place]) &gt; 0">
						<div>
							<h2>End Notes<small>
									<a href="#" id="toggle-rearnotes" class="toggle-btn">
										<span class="glyphicon glyphicon-triangle-right"/>
									</a>
								</small></h2>
							<section epub:type="rearnotes" style="display:none" id="section-rearnotes">
								<ul>
									<xsl:apply-templates select="tei:text/descendant::tei:note[@place]" mode="endnote"/>
								</ul>
							</section>
						</div>
					</xsl:if>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="tei:titleStmt/tei:title">
		<h2 itemprop="name">
			<xsl:value-of select="."/>
		</h2>
	</xsl:template>

	<xsl:template match="tei:teiHeader">
		<dl class="dl-horizontal">
			<xsl:apply-templates select="tei:fileDesc/tei:titleStmt"/>
			<xsl:apply-templates select="tei:fileDesc/tei:publicationStmt"/>
			<xsl:apply-templates select="tei:fileDesc/tei:sourceDesc/tei:bibl" mode="header"/>
		</dl>
	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<dt>Author</dt>
		<dd>
			<xsl:for-each select="tei:author">
				<a href="{$display_path}results?q=creator_facet:&#x022;{tei:name}&#x022;">
					<xsl:value-of select="tei:name"/>
				</a>
				<xsl:if test="tei:idno[@type='URI']">
					<a href="{tei:idno[@type='URI']}" title="{tei:idno[@type='URI']}" class="external-link" itemprop="author">
						<img src="{$display_path}ui/images/external.png" alt="External Link"/>
					</a>
				</xsl:if>
				<xsl:if test="not(position()=last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<dt>Publisher</dt>
		<dd>
			<xsl:for-each select="tei:publisher">
				<a href="{$display_path}results?q=publisher_facet:&#x022;{tei:name}&#x022;">
					<xsl:value-of select="tei:name"/>
				</a>
				<xsl:if test="tei:idno[@type='URI']">
					<a href="{tei:idno[@type='URI']}" title="{tei:idno[@type='URI']}" class="external-link" itemprop="publisher">
						<img src="{$display_path}ui/images/external.png" alt="External Link"/>
					</a>
				</xsl:if>
				<xsl:if test="not(position()=last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</dd>
		<dt>Place</dt>
		<dd>
			<xsl:value-of select="string-join(tei:pubPlace, ', ')"/>
		</dd>
		<dt>Date</dt>
		<dd itemprop="datePublished">
			<xsl:value-of select="tei:date"/>
		</dd>
	</xsl:template>

	<xsl:template match="tei:bibl" mode="header">
		<dt>Source</dt>
		<dd>
			<xsl:value-of select="tei:seg"/>
			<xsl:if test="tei:idno[@type='URI']">
				<a href="{tei:idno[@type='URI']}" title="{tei:idno[@type='URI']}" class="external-link" itemprop="sameAs">
					<img src="{$display_path}ui/images/external.png" alt="External Link"/>
				</a>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="tei:text">
		<!-- table of contents -->
		<xsl:call-template name="toc"/>
		<xsl:apply-templates/>
	</xsl:template>

	<!-- structural elements -->
	<xsl:template match="tei:front|tei:body|tei:back">
		<div>
			<h2 class="section-head">
				<xsl:value-of select="upper-case(local-name())"/>
				<xsl:if test="local-name()='front' or local-name()='back'">
					<small>
						<a href="#" id="toggle-{local-name()}" class="toggle-btn">
							<span class="glyphicon glyphicon-triangle-right"/>
						</a>
					</small>
				</xsl:if>
			</h2>
			<section id="section-{local-name()}" epub:type="{local-name()}matter">
				<xsl:if test="local-name()='front' or local-name()='back'">
					<xsl:attribute name="style">display:none</xsl:attribute>
				</xsl:if>
				<!-- call other content -->
				<xsl:apply-templates/>
			</section>
		</div>
	</xsl:template>

	<!-- *** TEMPLATES *** -->
	<!-- table of contents -->
	<xsl:template name="toc">
		<xsl:if test="count(descendant::tei:div1) &gt; 0">
			<h2>Table of Contents <small><a href="#" id="toggle-toc" class="toggle-btn"><span class="glyphicon glyphicon-triangle-right"/></a></small></h2>
			<section epub:type="toc" id="section-toc" style="display:none">
				<xsl:for-each select="*">
					<xsl:if test="count(tei:div1) &gt; 0">
						<h4>
							<xsl:value-of select="upper-case(local-name())"/>
						</h4>
						<nav>
							<ul class="toc">
								<xsl:apply-templates select="tei:div1|tei:titlePage" mode="toc"/>
							</ul>
						</nav>
					</xsl:if>
				</xsl:for-each>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- table of contents items -->
	<xsl:template match="tei:titlePage|tei:div1|tei:div2" mode="toc">
		<li>
			<a href="#{if (@xml:id) then @xml:id else generate-id()}">
				<xsl:choose>
					<xsl:when test="tei:head">
						<xsl:value-of select="tei:head"/>
					</xsl:when>
					<xsl:when test="self::tei:titlePage">Title Page</xsl:when>
					<xsl:otherwise>
						<i>[No title]</i>
					</xsl:otherwise>
				</xsl:choose>
			</a>

			<xsl:if test="child::tei:div2">
				<ul>
					<xsl:apply-templates select="tei:div2" mode="toc"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>

</xsl:stylesheet>
