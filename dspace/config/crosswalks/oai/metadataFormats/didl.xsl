<?xml version="1.0" encoding="UTF-8" ?>
<!-- http://www.openarchives.org/OAI/2.0/oai_dc.xsd -->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	<xsl:template match="/">
		<d:DIDL xmlns:d="urn:mpeg:mpeg21:2002:02-DIDL-NS" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="urn:mpeg:mpeg21:2002:02-DIDL-NS http://standards.iso.org/ittf/PubliclyAvailableStandards/MPEG-21_schema_files/did/didl.xsd">
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']">
			<d:DIDLInfo>
				<dcterms:created xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.org/dc/terms/ http://dublincore.org/schemas/xmls/qdc/dcterms.xsd">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field/text()" />
				</dcterms:created>
			</d:DIDLInfo>
			</xsl:if>
			<d:Item>
				<xsl:attribute name="id">
					<xsl:value-of select="concat('hdl_', translate(doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text(),'/','_'))" />
				</xsl:attribute>
				<d:Descriptor>
					<d:Statement mimeType="application/xml; charset=utf-8">
						<dii:Identifier xmlns:dii="urn:mpeg:mpeg21:2002:01-DII-NS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:mpeg:mpeg21:2002:01-DII-NS http://standards.iso.org/ittf/PubliclyAvailableStandards/MPEG-21_schema_files/dii/dii.xsd">urn:hdl:<xsl:value-of select="doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text()" /></dii:Identifier>
					</d:Statement>
				</d:Descriptor>
				<d:Descriptor>
					<d:Statement mimeType="application/xml; charset=utf-8">
						<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
								<dc:title><xsl:value-of select="." /></dc:title>
							</xsl:for-each>
							<!--  los autores se catalogan en dc.creator -->
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
								<dc:creator><xsl:value-of select="." /></dc:creator>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
								<dc:creator><xsl:value-of select="." /></dc:creator>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']/doc:element/doc:field[@name='value']">
								<dc:contributor><xsl:value-of select="." /></dc:contributor>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
								<dc:subject><xsl:value-of select="." /></dc:subject>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
								<dc:description><xsl:value-of select="." /></dc:description>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
								<dc:description><xsl:value-of select="." /></dc:description>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field[@name='value']">
								<dc:date><xsl:value-of select="." /></dc:date>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
								<dc:type><xsl:value-of select="." /></dc:type>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
								<dc:identifier><xsl:value-of select="." /></dc:identifier>
							</xsl:for-each>
							<!--  dc.language (Español, Inglés...) y dc.language.iso (es, en...) a ISO 639-3, sin repetidos.
							     "Otro" y los idiomas sin código general no se exportan. -->
							<xsl:variable name="languages">
								<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']//doc:field[@name='value']">
									<language>
										<xsl:call-template name="resolveLanguageCode">
											<xsl:with-param name="value" select="." />
										</xsl:call-template>
									</language>
								</xsl:for-each>
							</xsl:variable>
							<xsl:for-each select="$languages/language[. != '' and not(. = preceding-sibling::language)]">
								<dc:language><xsl:value-of select="." /></dc:language>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:element/doc:field[@name='value']">
								<dc:relation><xsl:value-of select="." /></dc:relation>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
								<dc:relation><xsl:value-of select="." /></dc:relation>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
								<dc:rights><xsl:value-of select="." /></dc:rights>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
								<dc:rights><xsl:value-of select="." /></dc:rights>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
								<dc:format><xsl:value-of select="." /></dc:format>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
								<dc:coverage><xsl:value-of select="." /></dc:coverage>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
								<dc:coverage><xsl:value-of select="." /></dc:coverage>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
								<dc:publisher><xsl:value-of select="." /></dc:publisher>
							</xsl:for-each>
							<!--  solo dc.publisher.degree, si es distinto de dc.publisher;
							     dc.publisher.location (lugar de publicación) no es una editorial -->
							<xsl:variable name="publishers" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']" />
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='degree']/doc:element/doc:field[@name='value']">
								<xsl:if test="not($publishers[. = current()])">
									<dc:publisher><xsl:value-of select="." /></dc:publisher>
								</xsl:if>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
								<dc:source><xsl:value-of select="." /></dc:source>
							</xsl:for-each>
							<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[not(@name='series' or @name='season' or @name='episode')]/doc:element/doc:field[@name='value']">
								<dc:source><xsl:value-of select="." /></dc:source>
							</xsl:for-each>
							<!--  serie, temporada y episodio (audio y video) se exportan juntos en un solo dc:source -->
							<xsl:variable name="seriesSource">
								<xsl:call-template name="seriesSourceText" />
							</xsl:variable>
							<xsl:if test="normalize-space($seriesSource) != ''">
								<dc:source><xsl:value-of select="normalize-space($seriesSource)" /></dc:source>
							</xsl:if>
						</oai_dc:dc>
					</d:Statement>
				</d:Descriptor>
				<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']">
					<xsl:if test="doc:field[@name='name']/text() = 'ORIGINAL'">
						<xsl:for-each select="doc:element[@name='bitstreams']/doc:element">
							<d:Component>
								<xsl:attribute name="id">
									<xsl:value-of select="translate(/doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text(),'/','_')"></xsl:value-of>_<xsl:value-of select="doc:field[@name='sid']/text()"></xsl:value-of>
								</xsl:attribute>
								<d:Resource>
									<xsl:attribute name="ref">
										<xsl:value-of select="doc:field[@name='url']/text()"></xsl:value-of>
									</xsl:attribute>
									<xsl:attribute name="mimeType">
										<xsl:value-of select="doc:field[@name='format']/text()"></xsl:value-of>
									</xsl:attribute>
								</d:Resource>
							</d:Component>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</d:Item>			
		</d:DIDL>
	</xsl:template>

	<!-- Serie / programa, temporada y episodio (audio y video) en un solo texto:
	     "Intelifilia, temporada 14, episodio 15". Las partes vacías se omiten. -->
	<xsl:template name="seriesSourceText">
		<xsl:variable name="source" select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='source']" />
		<xsl:variable name="series" select="normalize-space($source/doc:element[@name='series']/doc:element/doc:field[@name='value'][1])" />
		<xsl:variable name="season" select="normalize-space($source/doc:element[@name='season']/doc:element/doc:field[@name='value'][1])" />
		<xsl:variable name="episode" select="normalize-space($source/doc:element[@name='episode']/doc:element/doc:field[@name='value'][1])" />
		<xsl:value-of select="$series" />
		<xsl:if test="$season != ''">
			<xsl:if test="$series != ''"><xsl:text>, </xsl:text></xsl:if>
			<xsl:text>temporada </xsl:text><xsl:value-of select="$season" />
		</xsl:if>
		<xsl:if test="$episode != ''">
			<xsl:if test="$series != '' or $season != ''"><xsl:text>, </xsl:text></xsl:if>
			<xsl:text>episodio </xsl:text><xsl:value-of select="$episode" />
		</xsl:if>
	</xsl:template>

	<!-- Idioma (lista common_iso_languages o código ISO 639-1/639-3) a ISO 639-3.
	     Devuelve vacío para "Otro" y para Chinanteco, Mazateco, Totonaco y Mixe (sin código general). -->
	<xsl:template name="resolveLanguageCode">
		<xsl:param name="value" />
		<xsl:variable name="lc_value" select="translate(normalize-space($value), 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ', 'abcdefghijklmnopqrstuvwxyzáéíóúñ')" />
		<xsl:choose>
			<xsl:when test="contains('|español|espanol|spanish|es|es_mx|es_es|spa|', concat('|', $lc_value, '|'))">spa</xsl:when>
			<xsl:when test="contains('|inglés|ingles|english|en|en_us|eng|', concat('|', $lc_value, '|'))">eng</xsl:when>
			<xsl:when test="contains('|portugués|portugues|português|portuguese|pt|pt_br|por|', concat('|', $lc_value, '|'))">por</xsl:when>
			<xsl:when test="contains('|francés|frances|français|french|fr|fra|', concat('|', $lc_value, '|'))">fra</xsl:when>
			<xsl:when test="contains('|alemán|aleman|german|de|deu|', concat('|', $lc_value, '|'))">deu</xsl:when>
			<xsl:when test="contains('|italiano|italian|it|ita|', concat('|', $lc_value, '|'))">ita</xsl:when>
			<xsl:when test="contains('|mazahua|maz|', concat('|', $lc_value, '|'))">maz</xsl:when>
			<xsl:when test="contains('|otomí|otomi|ots|', concat('|', $lc_value, '|'))">ots</xsl:when>
			<xsl:when test="contains('|náhuatl|nahuatl|nah|', concat('|', $lc_value, '|'))">nah</xsl:when>
			<xsl:when test="contains('|matlatzinca|mat|', concat('|', $lc_value, '|'))">mat</xsl:when>
			<xsl:when test="contains('|tlahuica|ocu|', concat('|', $lc_value, '|'))">ocu</xsl:when>
			<xsl:when test="contains('|maya|yua|', concat('|', $lc_value, '|'))">yua</xsl:when>
			<xsl:when test="contains('|zapoteco|zap|', concat('|', $lc_value, '|'))">zap</xsl:when>
			<xsl:when test="contains('|chocho (chocholteco)|chocho|chocholteco|coz|', concat('|', $lc_value, '|'))">coz</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
