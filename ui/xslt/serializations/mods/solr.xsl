<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
	version="2.0" exclude-result-prefixes="#all">

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
			<field name="title" update="add">
				<xsl:value-of select="//mods:title"/>
			</field>
			<field name="author" update="add">
				<xsl:value-of select="//mods:namePart"/>
			</field>
			<field name="university" update="add">
				<xsl:value-of select="//mods:publisher"/>
			</field>
			<field name="timestamp" update="set">
				<xsl:value-of select="if (contains(string(current-dateTime()), 'Z')) then current-dateTime() else concat(string(current-dateTime()), 'Z')"/>
			</field>
			<field name="date" update="add">
				<xsl:value-of select="//mods:dateCreated"/>
			</field>
			<field name="abstract" update="add">
				<xsl:value-of select="//mods:abstract"/>
			</field>
			<field name="media_url" update="add">
				<xsl:value-of select="mods:location/mods:url"/>
			</field>

			<xsl:for-each select="mods:language">
				<field name="language" update="set">
					<xsl:value-of select="mods:languageTerm"/>
				</field>
			</xsl:for-each>

			<!-- subject facets -->
			<xsl:for-each select="mods:subject/*|mods:genre">
				<field name="{local-name()}_facet" update="set">
					<xsl:value-of select="."/>
				</field>
				<xsl:if test="string(@valueUri)">
					<field name="{local-name()}_uri" update="set">
						<xsl:value-of select="@valueUri"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</doc>
	</xsl:template>
</xsl:stylesheet>
