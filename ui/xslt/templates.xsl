<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="header">
		<!-- Static navbar -->
		<div class="navbar navbar-default navbar-static-top" role="navigation">
			<div class="container">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
					</button>
					<a class="navbar-brand" href="{//config/url}">
						<xsl:choose>
							<xsl:when test="string-length(//config/logo) &gt; 0">
								<xsl:choose>
									<xsl:when test="contains(//config/logo, 'http://')">
										<img src="{//config/logo}"/>
									</xsl:when>
									<xsl:otherwise>
										<img src="{$display_path}ui/images/{//config/logo}"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="//config/title"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</div>
				<div class="navbar-collapse collapse">
					<ul class="nav navbar-nav">
						<li>
							<a href="{$display_path}results">Browse</a>
						</li>
					</ul>
					<!--<div class="col-sm-3 col-md-3 pull-right">
						<form class="navbar-form" role="search" action="{//config/url}" method="get">
							<div class="input-group">
								<input type="text" class="form-control" placeholder="Search" name="q" id="srch-term"/>
								<div class="input-group-btn">
									<button class="btn btn-default" type="submit">
										<i class="glyphicon glyphicon-search"/>
									</button>
								</div>
							</div>
						</form>
					</div>-->
				</div>
				<!--/.nav-collapse -->
			</div>
		</div>
	</xsl:template>

	<xsl:template name="footer">
		<xsl:copy-of select="/content/content/footer"/>
	</xsl:template>

</xsl:stylesheet>
