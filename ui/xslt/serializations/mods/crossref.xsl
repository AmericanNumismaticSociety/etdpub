<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns="http://www.crossref.org/schema/4.3.7" version="2.0" exclude-result-prefixes="#all">

<xsl:template match="/">
	<doi_batch version="4.3.7"
		xmlns="http://www.crossref.org/schema/4.3.7"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.crossref.org/schema/4.3.7
		http://www.crossref.org/schemas/crossref4.3.7.xsd">
		<head>
			<doi_batch_id></doi_batch_id>
			<timestamp></timestamp>
			<depositor>
				<depositor_name></depositor_name>
				<email_address></email_address>
			</depositor>
			<registrant></registrant>
		</head>
		<body>
			<xsl:apply-templates select="//mods:mods"/>
		</body>
	</doi_batch>
	
	</xsl:template>

	<xsl:template match="mods:mods">
		
	</xsl:template>
</xsl:stylesheet>
