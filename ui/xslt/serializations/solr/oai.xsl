<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="solr-url" select="concat(/content/config/solr/url, 'select/')"/>

	<!-- request params -->
	<xsl:param name="verb" select="doc('input:request')/request/parameters/parameter[name='verb']/value"/>
	<xsl:param name="metadataPrefix" select="doc('input:request')/request/parameters/parameter[name='metadataPrefix']/value"/>
	<xsl:param name="set" select="doc('input:request')/request/parameters/parameter[name='set']/value"/>
	<xsl:param name="identifier" select="doc('input:request')/request/parameters/parameter[name='identifier']/value"/>
	<xsl:param name="from" select="doc('input:request')/request/parameters/parameter[name='from']/value"/>
	<xsl:param name="until" select="doc('input:request')/request/parameters/parameter[name='until']/value"/>
	<xsl:param name="resumptionToken" select="doc('input:request')/request/parameters/parameter[name='resumptionToken']/value"/>

	<!-- validate from, until, resumptionToken -->
	<xsl:variable name="from-validate" as="xs:boolean" select="$from castable as xs:date"/>
	<xsl:variable name="until-validate" as="xs:boolean" select="$until castable as xs:date"/>

	<xsl:variable name="resumptionToken-validate" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="string($resumptionToken)">
				<xsl:choose>
					<xsl:when test="descendant::doc[str[@name='oai_id']=$resumptionToken]">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="publisher" select="/content/config/publisher"/>
	<xsl:variable name="publisher_email" select="/content/config/publisher_email"/>
	<xsl:variable name="publisher_code" select="/content/config/publisher_code"/>

	<xsl:template match="/">
		<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
			http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
			<responseDate>
				<xsl:variable name="timestamp" select="concat(substring-before(string(current-dateTime()), '.'), 'Z')"/>
				<xsl:value-of select="$timestamp"/>
			</responseDate>
			<request verb="{$verb}">
				<xsl:if test="string($metadataPrefix)">
					<xsl:attribute name="metadataPrefix" select="$metadataPrefix"/>
				</xsl:if>
				<xsl:if test="string($set)">
					<xsl:attribute name="set" select="$set"/>
				</xsl:if>
				<xsl:if test="string($identifier)">
					<xsl:attribute name="identifier" select="$identifier"/>
				</xsl:if>
				<xsl:value-of select="concat($url, 'oai/')"/>
			</request>
			<xsl:choose>
				<xsl:when test="$verb='Identify'">
					<Identify>
						<repositoryName>
							<xsl:value-of select="$publisher"/>
						</repositoryName>
						<baseURL>
							<xsl:value-of select="concat($url, 'oai/')"/>
						</baseURL>
						<protocolVersion>2.0</protocolVersion>
						<adminEmail>
							<xsl:value-of select="$publisher_email"/>
						</adminEmail>
						<earliestDatestamp>
							<xsl:value-of select="substring-before(descendant::doc[last()]/date[@name='timestamp'], 'T')"/>
						</earliestDatestamp>
						<deletedRecord>no</deletedRecord>
						<granularity>YYYY-MM-DD</granularity>
						<description>
							<oai-identifier xmlns="http://www.openarchives.org/OAI/2.0/oai-identifier" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai-identifier         http://www.openarchives.org/OAI/2.0/oai-identifier.xsd">
								<scheme>oai</scheme>
								<repositoryIdentifier>
									<xsl:value-of select="doc('input:request')/request/server-name"/>
								</repositoryIdentifier>
								<delimiter>:</delimiter>
								<sampleIdentifier>
									<xsl:value-of select="descendant::doc[1]/str[@name='oai_id']"/>
								</sampleIdentifier>
							</oai-identifier>
						</description>
					</Identify>
				</xsl:when>
				<xsl:when test="$verb='ListSets'">
					<ListSets>
						<set>
							<setSpec>etdpub</setSpec>
							<setName>Digital Library collection of <xsl:value-of select="$publisher"/></setName>
							<setDescription>
								<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
									xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/           http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
									<dc:title xml:lang="en">Digital Library collection of collection of <xsl:value-of select="$publisher"/></dc:title>
									<dc:creator>
										<xsl:value-of select="$publisher"/>
									</dc:creator>
								</oai_dc:dc>
							</setDescription>
						</set>
					</ListSets>
				</xsl:when>
				<xsl:when test="$verb='ListMetadataFormats'">
					<ListMetadataFormats>
						<metadataFormat>
							<metadataPrefix>oai_dc</metadataPrefix>
							<schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</schema>
							<metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</metadataNamespace>
						</metadataFormat>
					</ListMetadataFormats>
				</xsl:when>
				<xsl:when test="$verb='ListRecords'">
					<xsl:choose>
						<xsl:when test="string($resumptionToken)">
							<xsl:choose>
								<xsl:when test="$resumptionToken-validate=false()">
									<error code="badResumptionToken">Invalid resumptionToken</error>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($metadataPrefix)">
											<xsl:choose>
												<xsl:when test="$metadataPrefix='oai_dc'">
													<!-- test resumptionToken -->
													<xsl:call-template name="validate-lists"/>
												</xsl:when>
												<xsl:otherwise>
													<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<error code="badArgument">No metadata prefix</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($metadataPrefix)">
									<xsl:choose>
										<xsl:when test="$metadataPrefix='oai_dc'">
											<!-- test resumptionToken -->
											<xsl:call-template name="validate-lists"/>
										</xsl:when>
										<xsl:otherwise>
											<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<error code="badArgument">No metadata prefix</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$verb='ListIdentifiers'">
					<xsl:choose>
						<xsl:when test="string($resumptionToken)">
							<xsl:choose>
								<xsl:when test="$resumptionToken-validate=false()">
									<error code="badResumptionToken">Invalid resumptionToken</error>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($metadataPrefix)">
											<xsl:choose>
												<xsl:when test="$metadataPrefix='oai_dc'">
													<!-- test resumptionToken -->
													<xsl:call-template name="validate-lists"/>
												</xsl:when>
												<xsl:otherwise>
													<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<error code="badArgument">No metadata prefix</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($metadataPrefix)">
									<xsl:choose>
										<xsl:when test="$metadataPrefix='oai_dc'">
											<!-- test resumptionToken -->
											<xsl:call-template name="validate-lists"/>
										</xsl:when>
										<xsl:otherwise>
											<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<error code="badArgument">No metadata prefix</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$verb='GetRecord'">
					<xsl:choose>
						<xsl:when test="$identifier">
							<xsl:variable name="identifier-validate" select="iri-to-uri($identifier) castable as xs:anyURI" as="xs:boolean"/>
							<xsl:variable name="character-pass" as="xs:boolean">
								<xsl:choose>
									<xsl:when test="$identifier-validate=true()">
										<xsl:choose>
											<xsl:when test="contains($identifier, '!') or contains($identifier, '&#x022;') or contains($identifier, '#') or contains($identifier, '[') or
												contains($identifier, ']') or contains($identifier, '(') or contains($identifier, ')') or contains($identifier, '{') or contains($identifier, '}')"
												>false</xsl:when>
											<xsl:otherwise>true</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="string($metadataPrefix) and $character-pass=true()">
									<xsl:choose>
										<xsl:when test="$metadataPrefix='oai_dc'">
											<GetRecord>
												<xsl:apply-templates select="descendant::doc" mode="ListRecords"/>
											</GetRecord>
										</xsl:when>
										<xsl:otherwise>
											<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<error code="badArgument">Bad OAI Argument</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<error code="badArgument">Bad OAI Argument: No identifier</error>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
				<xsl:otherwise>
					<error code="badVerb">Illegal OAI verb</error>
				</xsl:otherwise>
			</xsl:choose>
		</OAI-PMH>
	</xsl:template>

	<xsl:template match="doc" mode="ListIdentifiers">
		<header>
			<identifier>
				<xsl:value-of select="str[@name='oai_id']"/>
			</identifier>
			<datestamp>
				<xsl:value-of select="date[@name='timestamp']"/>
			</datestamp>
			<setSpec>etdpub</setSpec>
		</header>
	</xsl:template>

	<xsl:template match="doc" mode="ListRecords">
		<record>
			<header>
				<identifier>
					<xsl:value-of select="str[@name='oai_id']"/>
				</identifier>
				<datestamp>
					<xsl:value-of select="substring-before(date[@name='timestamp'], 'T')"/>
				</datestamp>
				<setSpec>etdpub</setSpec>
			</header>
			<metadata>
				<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
					xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/      http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
					<dc:title>
						<xsl:value-of select="str[@name='title']"/>
					</dc:title>
					<xsl:for-each select="arr[@name='creator_facet']/str">
						<dc:creator>
							<xsl:value-of select="."/>
						</dc:creator>
					</xsl:for-each>
					<dc:abstract>
						<xsl:value-of select="str[@name='abstract']"/>
					</dc:abstract>
					<dc:identifier>
						<xsl:variable name="objectUri">
							<xsl:choose>
								<xsl:when test="//config/ark[@enabled='true']">
									<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', str[@name='id'])"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($url, 'id/', str[@name='id'])"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:value-of select="$objectUri"/>
					</dc:identifier>
					<dc:rights>
						<xsl:value-of select="str[@name='right']"/>
					</dc:rights>
					<xsl:if test="string(str[@name='date'])">
						<dc:date>
							<xsl:value-of select="str[@name='date']"/>
						</dc:date>
					</xsl:if>
					<xsl:for-each select="arr[@name='language_facet']/str">
						<dc:language>
							<xsl:value-of select="."/>
						</dc:language>
					</xsl:for-each>
					<xsl:for-each select="arr[@name='topic_facet']/str">
						<dc:subject>
							<xsl:value-of select="."/>
						</dc:subject>
					</xsl:for-each>
					<xsl:for-each select="arr[@name='geographic_facet']/str">
						<dc:coverage>
							<xsl:value-of select="."/>
						</dc:coverage>
					</xsl:for-each>
					<!--<dc:rights></dc:rights>-->
				</oai_dc:dc>
			</metadata>
		</record>
	</xsl:template>

	<xsl:template name="validate-lists">
		<xsl:choose>
			<!-- if there is a string for $from or $until both both of them are invalid dates, output badArgument -->
			<xsl:when test="string(normalize-space($from)) or string(normalize-space($until))">
				<xsl:choose>
					<xsl:when test="string($from) and string($until)">
						<xsl:choose>
							<xsl:when test="$from-validate=false() or $until-validate=false()">
								<error code="badArgument">From or Until arguments invalid</error>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$verb='ListRecords'">
										<xsl:call-template name="list-records"/>
									</xsl:when>
									<xsl:when test="$verb='ListIdentifiers'">
										<xsl:call-template name="list-identifiers"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string($from) and not(string($until))">
						<xsl:choose>
							<xsl:when test="$from-validate=false()">
								<error code="badArgument">From argument invalid</error>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$verb='ListRecords'">
										<xsl:call-template name="list-records"/>
									</xsl:when>
									<xsl:when test="$verb='ListIdentifiers'">
										<xsl:call-template name="list-identifiers"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="not(string($from)) and string($until)">
						<xsl:choose>
							<xsl:when test="$until-validate=false()">
								<error code="badArgument">Until argument invalid</error>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$verb='ListRecords'">
										<xsl:call-template name="list-records"/>
									</xsl:when>
									<xsl:when test="$verb='ListIdentifiers'">
										<xsl:call-template name="list-identifiers"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$verb='ListRecords'">
						<xsl:call-template name="list-records"/>
					</xsl:when>
					<xsl:when test="$verb='ListIdentifiers'">
						<xsl:call-template name="list-identifiers"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="list-records">
		<xsl:choose>
			<xsl:when test="count(descendant::doc)=0">
				<error code="noRecordsMatch">No matching records in date range</error>
			</xsl:when>
			<xsl:otherwise>
				<ListRecords>
					<xsl:apply-templates select="descendant::doc" mode="ListRecords"/>
				</ListRecords>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="list-identifiers">
		<xsl:choose>
			<xsl:when test="count(descendant::doc)=0">
				<error code="noRecordsMatch">No matching records in date range</error>
			</xsl:when>
			<xsl:otherwise>
				<ListIdentifiers>
					<xsl:apply-templates select="descendant::doc" mode="ListIdentifiers"/>
				</ListIdentifiers>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
