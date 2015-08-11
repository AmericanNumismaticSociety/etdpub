<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>

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
			<field name="title">
				<xsl:value-of select="//mods:title"/>
			</field>
			<field name="author">
				<xsl:value-of select="//mods:namePart"/>
			</field>
			<field name="university">
				<xsl:value-of select="//mods:publisher"/>
			</field>
			<field name="timestamp">
				<xsl:value-of select="if (contains(string(current-dateTime()), 'Z')) then current-dateTime() else concat(string(current-dateTime()), 'Z')"/>
			</field>
			<field name="date">
				<xsl:value-of select="//mods:dateCreated"/>
			</field>			
			<field name="abstract">
				<xsl:value-of select="//mods:abstract"/>
			</field>
			<field name="media_url">
				<xsl:value-of select="mods:location/mods:url"/>
			</field>
			
			<xsl:for-each select="mods:language">
				<field name="language">
					<xsl:value-of select="mods:languageTerm"/>
				</field>
			</xsl:for-each>
			
			<!-- subject facets -->
			<xsl:for-each select="mods:subject/*|mods:genre">
				<field name="{local-name()}_facet">
					<xsl:value-of select="."/>
				</field>
				<xsl:if test="string(@valueUri)">
					<field name="{local-name()}_uri">
						<xsl:value-of select="@valueUri"/>
					</field>
				</xsl:if>
			</xsl:for-each>
			
			<!-- fulltext -->
			<field name="text">
				<xsl:variable name="text">
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:value-of select="normalize-space($text)"/>
			</field>
		</doc>
	</xsl:template>
</xsl:stylesheet>
