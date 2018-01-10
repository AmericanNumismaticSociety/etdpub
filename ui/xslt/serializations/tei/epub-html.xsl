<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:etdpub="https://github.com/AmericanNumismaticSociety/etdpub"
	xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="tei xs xlink etdpub" version="2.0">
	<!-- xml method must be explicitly forced, or else the meta element does not conform to EPUB validation (defaults to xhtml) -->
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:include href="xhtml-templates.xsl"/>

	<!-- variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="/content/config/ark/@enabled='true'">
				<xsl:value-of select="concat(/content/config/url, 'ark:/', /content/config/ark/naan, '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(/content/config/url, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/tei:TEI"/>


	</xsl:template>

	<xsl:template match="tei:TEI">
		<xsl:variable name="funder" select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:funder"/>

		<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<title>
					<xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
				</title>
				<link rel="stylesheet" href="css/style.css"/>
			</head>
			<body>
				<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
				<!--<xsl:apply-templates select="//tei:titlePage">
					<xsl:with-param name="funder" select="$funder"/>
				</xsl:apply-templates>-->
				<xsl:for-each select="descendant::tei:div1">
					<xsl:result-document href="file:///tmp/{$id}-{parent::node()/local-name()}-{format-number(position(), '000')}.xhtml">
						<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
							<head>
								<title>
									<xsl:value-of
										select="
											if (self::tei:titlePage) then
												'Title Page'
											else
												tei:head"/>
								</title>
								<xsl:element name="meta">
									<xsl:attribute name="http-equiv">content-type</xsl:attribute>
									<xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
								</xsl:element>
								<link rel="stylesheet" href="css/style.css"/>
							</head>
							<body>
								<section epub:type="{if (self::tei:titlePage) then 'titlepage' else @type}">
									<xsl:apply-templates select="*[not(self::tei:note[@place])]"/>
								</section>
								<xsl:if test="count(descendant::tei:note[@place]) &gt; 0">
									<section epub:type="rearnotes" id="{@xml:id}-rearnotes">
										<xsl:element name="h{number(substring-after(local-name(), 'div')) + 2}">
											<xsl:text>End Notes</xsl:text>
										</xsl:element>
										<ul style="list-style-type:none">
											<xsl:apply-templates select="descendant::tei:note[@place]"/>
										</ul>
									</section>
								</xsl:if>
							</body>
						</html>
					</xsl:result-document>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:result-document href="file:///tmp/{$id}-titlePage.xhtml">
			<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
				<head>
					<title>Title Page</title>
					<xsl:element name="meta">
						<xsl:attribute name="http-equiv">content-type</xsl:attribute>
						<xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
					</xsl:element>
					<link rel="stylesheet" href="css/style.css"/>
				</head>
				<body>
					<section epub:type="titlepage" id="{if (@xml:id) then @xml:id else generate-id()}" style="text-align:center">
						<xsl:apply-templates select="tei:titleStmt | tei:seriesStmt"/>
						<xsl:apply-templates select="tei:publicationStmt"/>
						<xsl:apply-templates select="tei:titleStmt/tei:funder"/>
					</section>
				</body>
			</html>
		</xsl:result-document>


	</xsl:template>

	<xsl:template match="tei:titleStmt">
		<h2>
			<xsl:value-of select="tei:title"/>
		</h2>
		<xsl:if test="tei:subtitle">
			<h3>
				<xsl:value-of select="tei:subtitle"/>
			</h3>
		</xsl:if>
		<xsl:for-each select="tei:author">
			<div>
				<xsl:value-of select="tei:name"/>
			</div>
		</xsl:for-each>
		<xsl:if test="tei:editor">
			<div>
				<xsl:choose>
					<xsl:when test="count(tei:editor) = 1">
						<xsl:value-of select="tei:editor/tei:name"/>
						<xsl:text>, Ed.</xsl:text>
					</xsl:when>
					<xsl:when test="count(tei:editor) = 2">
						<xsl:value-of select="string-join(tei:editor/tei:name, ' and ')"/>
						<xsl:text>, Eds.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="tei:editor">
							<xsl:value-of select="tei:name"/>
							<xsl:text>, </xsl:text>
							<xsl:if test="position() = last()">
								<xsl:text>and </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text>, Eds.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:seriesStmt">
		<div margin-top="20px" margin-bottom="20px">
			<div>
				<xsl:value-of select="tei:title"/>
			</div>

			<xsl:apply-templates select="tei:biblScope"/>
		</div>
	</xsl:template>

	<xsl:template match="tei:biblScope">
		<div>
			<xsl:value-of select="concat(upper-case(substring(@unit, 1, 1)), substring(@unit, 2))"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="."/>
		</div>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<div>
			<div>
				<img src="http://numismatics.org/digitallibrary/ui/images/ans-logo.png"
					width="200px"/>
			</div>
			<div>
				<xsl:value-of select="tei:publisher/tei:name"/>
			</div>
			<xsl:if test="tei:pubPlace">
				<div>
					<xsl:value-of select="tei:pubPlace"/>
				</div>
			</xsl:if>
			<xsl:if test="tei:date">
				<div margin-top="20px">
					<div><b>Original Publication:</b></div>
					<div>
						<xsl:value-of select="tei:date"/>
					</div>
				</div>
			</xsl:if>

			<!-- digital Edition -->
			<div margin-top="20px">
				<div><b>Digital Edition:</b></div>
				<div>
					<a href="{concat($uri_space, $id)}">
						<xsl:value-of select="concat($uri_space, $id)"/>
					</a>
				</div>
				<div>
					<xsl:value-of select="format-date(ancestor::tei:teiHeader/tei:revisionDesc/tei:change[last()]/@when, '[D] [MNn] [Y0001]')"/>
				</div>

				<xsl:apply-templates select="tei:availability/tei:licence"/>
			</div>

		</div>
	</xsl:template>

	<xsl:template match="tei:licence">
		<div>
			<a href="{@target}">
				<xsl:value-of select="."/>
			</a>
		</div>
	</xsl:template>
	
	<xsl:template match="tei:funder">
		<div margin-top="20px">
			<xsl:value-of select="."/>
		</div>
	</xsl:template>


	<xsl:template match="tei:titlePage">
		<xsl:param name="funder"/>

		<xsl:result-document href="file:///tmp/{$id}-titlePage.xhtml">
			<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
				<head>
					<title>Title Page</title>
					<xsl:element name="meta">
						<xsl:attribute name="http-equiv">content-type</xsl:attribute>
						<xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
					</xsl:element>
					<link rel="stylesheet" href="css/style.css"/>
				</head>
				<body>
					<section epub:type="titlepage" id="{if (@xml:id) then @xml:id else generate-id()}" style="text-align:center">
						<xsl:apply-templates mode="titlePage"/>
					</section>

					<xsl:if test="string($funder)">
						<section epub:type="acknowledgments" id="{generate-id()}" style="text-align:center">
							<xsl:value-of select="$funder"/>
						</section>
					</xsl:if>
				</body>
			</html>
		</xsl:result-document>

	</xsl:template>

	<!--<xsl:template match="tei:teiHeader">
		<xsl:result-document href="file:///tmp/{$id}-teiHeader.xhtml">
			<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns="http://www.w3.org/1999/xhtml">
				<head>
					<title>
						<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title"/>
					</title>
					<meta http-equiv="content-type" content="text/html; charset=utf-8" />
					<link rel="stylesheet" href="css/style.css"/>
				</head>
				<body>
					<section epub:type="titlepage">
						<div>
							<h2>
								<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title"/>
							</h2>
							<h4>
								<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:author"/>
							</h4>
						</div>
					</section>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>-->
</xsl:stylesheet>
