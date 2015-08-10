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

			<field name="timestamp"> </field>
			<field name="text">
				<xsl:for-each select="descendant-or-self::node()">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>
</xsl:stylesheet>
