<?xml version="1.0" encoding="UTF-8" ?>
<!--  http://www.openarchives.org/OAI/2.0/oai_dc.xsl-->
<!--
	https://guidelines.openaire.eu/en/latest/literature/index_guidelines-lit_v3.html
-->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />

	<xsl:variable name="driverPrefix" select="'info:eu-repo/semantics/'" />

	<xsl:template match="/">
		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
			xmlns:dc="http://purl.org/dc/elements/1.1/" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			<!-- dc.title -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>
			<!-- dc.title.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>
			<!-- dc.creator -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>
			<!-- dc.contributor.author -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>
			<!-- dc.contributor.* (!author) -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']/doc:element/doc:field[@name='value']">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>
			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>
			<!-- dc.subject -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<dc:subject><xsl:value-of select="." /></dc:subject>
			</xsl:for-each>
			<!-- dc.subject.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
				<dc:subject><xsl:value-of select="." /></dc:subject>
			</xsl:for-each>
			<!-- dc.description -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			<!-- dc.description.* (not provenance)-->
			<!--  dc.description.pages no se exporta: Dublin Core simple / OpenAIRE 3 no tienen campo para la extensión -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance' and @name!='pages']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			<!--  dc.abstract (campo heredado de importaciones) -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			<!-- dc.date -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="." /></dc:date>
			</xsl:for-each>
			<!-- dc.date.* -->
			<!--  DRIVER / OpenAIRE solo admiten la fecha de publicación (dc.date.issued, AAAA-MM-DD)
			     y el fin de embargo (info:eu-repo/date/embargoEnd/AAAA-MM-DD); se omiten accessioned y available -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="substring(normalize-space(.), 1, 10)" /></dc:date>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='embargo']/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="concat('info:eu-repo/date/embargoEnd/', substring(normalize-space(.), 1, 10))" /></dc:date>
			</xsl:for-each>
			<!-- dc.type -->
			<!--  tipo de documento (lista common_types) al vocabulario DRIVER -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<dc:type>
					<xsl:value-of select="$driverPrefix" />
					<xsl:call-template name="resolveDriverType">
						<xsl:with-param name="field" select="." />
					</xsl:call-template>
				</dc:type>
			</xsl:for-each>
			<!-- dc.type.* -->
			<!--  versión (dc.type.publicationversion, lista openaire_version_types) al vocabulario DRIVER;
			     los demás dc.type.* no se exportan porque no pertenecen a ningún vocabulario -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='publicationversion' or @name='version']/doc:element/doc:field[@name='value'][1]">
				<xsl:variable name="version">
					<xsl:call-template name="resolveDriverVersion">
						<xsl:with-param name="field" select="." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$version != ''">
					<dc:type><xsl:value-of select="concat($driverPrefix, $version)" /></dc:type>
				</xsl:if>
			</xsl:for-each>
			<!-- dc.identifier -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
			<!-- dc.identifier.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
			<!-- dc.language -->
			<!-- dc.language.* -->
			<!--  dc.language (Español, Inglés...) y dc.language.iso (es, en...) a ISO 639-3, sin repetidos.
			     "Otro" no se exporta. -->
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
			<!-- dc.relation -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			<!-- dc.relation.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			<!--  identificadores alternos según OpenAIRE 3 (DOI del recurso e ISSN de la revista) -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<dc:relation>
					<xsl:text>info:eu-repo/semantics/altIdentifier/doi/</xsl:text>
					<xsl:call-template name="stripDOIResolver">
						<xsl:with-param name="value" select="normalize-space(.)" />
					</xsl:call-template>
				</dc:relation>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="concat('info:eu-repo/semantics/altIdentifier/issn/', normalize-space(.))" /></dc:relation>
			</xsl:for-each>
			<!--  ISBN del libro; también se conserva en dc:identifier -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="concat('info:eu-repo/semantics/altIdentifier/isbn/', normalize-space(.))" /></dc:relation>
			</xsl:for-each>
			<!-- dc.rights -->
			<!-- dc.rights.* -->
			<!--  una sola condición de acceso DRIVER (info:eu-repo/semantics/openAccess...), tomada de
			     dc.rights.accesslevel, dc.rights o el mecanismo access status; después la licencia
			     (dcterms.license.uri o dc.rights.uri) y otros textos de dc.rights -->
			<xsl:call-template name="rights" />
			<!-- dc.format -->
			<!-- dc.format.* -->
			<!--  DRIVER / OpenAIRE piden tipos MIME. Se usan los de los archivos (bundle ORIGINAL) y
			     dc.format (PDF, JPEG...) traducido a MIME, para los ítems sin archivos. Sin repetidos. -->
			<xsl:variable name="formats">
				<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name'][text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
					<format><xsl:value-of select="normalize-space(.)" /></format>
				</xsl:for-each>
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']//doc:field[@name='value']">
					<format>
						<xsl:call-template name="resolveMimeType">
							<xsl:with-param name="value" select="." />
						</xsl:call-template>
					</format>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each select="$formats/format[. != '' and not(. = preceding-sibling::format)]">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each>
			<!-- dc.coverage -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
				<dc:coverage><xsl:value-of select="." /></dc:coverage>
			</xsl:for-each>
			<!-- dc.coverage.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
				<dc:coverage><xsl:value-of select="." /></dc:coverage>
			</xsl:for-each>
			<!-- dc.audience -->
			<!--  público destinatario (lista openaire_audience) al vocabulario de OpenAIRE en inglés, sin repetidos
			     https://guidelines.openaire.eu/en/latest/literature/field_audience.html -->
			<xsl:variable name="audiences">
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='audience']/doc:element/doc:field[@name='value']">
					<audience>
						<xsl:call-template name="resolveAudience">
							<xsl:with-param name="field" select="." />
						</xsl:call-template>
					</audience>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each select="$audiences/audience[. != '' and not(. = preceding-sibling::audience)]">
				<dc:audience><xsl:value-of select="." /></dc:audience>
			</xsl:for-each>
			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<dc:publisher><xsl:value-of select="." /></dc:publisher>
			</xsl:for-each>
			<!-- dc.publisher.* -->
			<!--  solo dc.publisher.degree (institución que otorga el grado); no se repite si es igual a dc.publisher.
			     dc.publisher.location (lugar de publicación) no es una editorial y no se exporta. -->
			<xsl:variable name="publishers" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']" />
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='degree']/doc:element/doc:field[@name='value']">
				<xsl:if test="not($publishers[. = current()])">
					<dc:publisher><xsl:value-of select="." /></dc:publisher>
				</xsl:if>
			</xsl:for-each>
			<!-- dc.source -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<dc:source><xsl:value-of select="." /></dc:source>
			</xsl:for-each>
			<!--  OpenAIRE 3 usa dc:source para la cita de la fuente (revista, volumen, páginas).
			     Se toma dc.bibliographicCitation y, si no existe, dc.source.journal.
			     dc.source.issn va en dc:relation; dc.source.volume y dc.source.elocator ya forman parte de la cita. -->
			<xsl:variable name="citations" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='bibliographicCitation']/doc:element/doc:field[@name='value']" />
			<xsl:for-each select="$citations">
				<dc:source><xsl:value-of select="normalize-space(.)" /></dc:source>
			</xsl:for-each>
			<!-- dc.source.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[not(@name='issn' or @name='volume' or @name='elocator' or (@name='journal' and $citations))]/doc:element/doc:field[@name='value']">
				<dc:source><xsl:value-of select="." /></dc:source>
			</xsl:for-each>
		</oai_dc:dc>
	</xsl:template>

	<!--  -->
	<!--  vocabularios DRIVER / OpenAIRE 3 para los valores de las plantillas de catalogación -->
	<!--  -->

	<!-- dc:rights: condición de acceso, licencia y otros textos -->
	<xsl:template name="rights">
		<xsl:variable name="dcRights" select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']" />
		<!-- 1. dc.rights.accesslevel (valor catalogado) -->
		<xsl:variable name="accessFromLevel">
			<xsl:call-template name="resolveDriverAccess">
				<xsl:with-param name="field" select="$dcRights/doc:element[@name='accesslevel']/doc:element/doc:field[@name='value'][1]" />
			</xsl:call-template>
		</xsl:variable>
		<!-- 2. dc.rights (en /driver ya viene como info:eu-repo/semantics/openAccess) -->
		<xsl:variable name="accessFromRightsList">
			<xsl:for-each select="$dcRights/doc:element/doc:field[@name='value']">
				<access>
					<xsl:call-template name="resolveDriverAccess">
						<xsl:with-param name="field" select="." />
					</xsl:call-template>
				</access>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="accessFromRights" select="string($accessFromRightsList/access[. != ''][1])" />
		<!-- 3. mecanismo access status de DSpace (permisos reales de los archivos) -->
		<xsl:variable name="accessStatus" select="/doc:metadata/doc:element[@name='others']/doc:element[@name='access-status']/doc:field[@name='value']" />
		<xsl:variable name="accessFromStatus">
			<xsl:choose>
				<xsl:when test="$accessStatus = 'open.access'">openAccess</xsl:when>
				<xsl:when test="$accessStatus = 'embargo'">embargoedAccess</xsl:when>
				<xsl:when test="$accessStatus = 'restricted'">restrictedAccess</xsl:when>
				<xsl:when test="$accessStatus = 'metadata.only'">closedAccess</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="access">
			<xsl:choose>
				<xsl:when test="$accessFromLevel != ''"><xsl:value-of select="$accessFromLevel" /></xsl:when>
				<xsl:when test="$accessFromRights != ''"><xsl:value-of select="$accessFromRights" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="$accessFromStatus" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$access != ''">
			<dc:rights><xsl:value-of select="concat($driverPrefix, $access)" /></dc:rights>
		</xsl:if>
		<!-- textos de dc.rights que no son una condición de acceso (p. ej. derechos de autor) -->
		<xsl:for-each select="$dcRights/doc:element/doc:field[@name='value']">
			<xsl:variable name="isAccess">
				<xsl:call-template name="resolveDriverAccess">
					<xsl:with-param name="field" select="." />
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$isAccess = ''">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:if>
		</xsl:for-each>
		<!-- licencia: dc.rights.uri y dcterms.license.uri (o su nombre si no hay URI) -->
		<xsl:variable name="rightsURIs" select="$dcRights/doc:element[@name='uri']/doc:element/doc:field[@name='value']" />
		<xsl:for-each select="$rightsURIs">
			<dc:rights><xsl:value-of select="." /></dc:rights>
		</xsl:for-each>
		<xsl:variable name="license" select="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='license']" />
		<xsl:variable name="licenseURI" select="normalize-space($license/doc:element[@name='uri']/doc:element/doc:field[@name='value'][1])" />
		<xsl:variable name="licenseName" select="normalize-space($license/doc:element/doc:field[@name='value'][1])" />
		<xsl:choose>
			<xsl:when test="$licenseURI != ''">
				<xsl:if test="not($rightsURIs[normalize-space(.) = $licenseURI])">
					<dc:rights><xsl:value-of select="$licenseURI" /></dc:rights>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$licenseName != ''">
				<dc:rights><xsl:value-of select="$licenseName" /></dc:rights>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Condición de acceso (dc.rights.accesslevel en español, COAR o DRIVER) al término DRIVER.
	     Devuelve vacío si el valor no es una condición de acceso. -->
	<xsl:template name="resolveDriverAccess">
		<xsl:param name="field" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="normalizeVocabularyValue">
				<xsl:with-param name="value" select="$field" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lc_value = 'acceso abierto' or $lc_value = 'open access' or $lc_value = 'openaccess' or $lc_value = 'http://purl.org/coar/access_right/c_abf2'">openAccess</xsl:when>
			<xsl:when test="$lc_value = 'acceso bajo embargo' or $lc_value = 'acceso embargado' or $lc_value = 'embargoed access' or $lc_value = 'embargoedaccess' or $lc_value = 'http://purl.org/coar/access_right/c_f1cf'">embargoedAccess</xsl:when>
			<xsl:when test="$lc_value = 'acceso restringido' or $lc_value = 'restricted access' or $lc_value = 'restrictedaccess' or $lc_value = 'http://purl.org/coar/access_right/c_16ec'">restrictedAccess</xsl:when>
			<xsl:when test="$lc_value = 'acceso cerrado' or $lc_value = 'closed access' or $lc_value = 'closedaccess' or $lc_value = 'metadata only access' or $lc_value = 'http://purl.org/coar/access_right/c_14cb'">closedAccess</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Tipo de documento (lista common_types, en español, o término DRIVER/COAR en inglés) al término DRIVER.
	     La tesis se precisa con cm.degree.level. Lo que no tiene equivalente se exporta como "other". -->
	<xsl:template name="resolveDriverType">
		<xsl:param name="field" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="normalizeVocabularyValue">
				<xsl:with-param name="value" select="$field" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lc_value = 'tesis' or $lc_value = 'thesis'">
				<xsl:variable name="lc_degree_level">
					<xsl:call-template name="lowercase">
						<xsl:with-param name="value" select="normalize-space(/doc:metadata/doc:element[@name='cm']/doc:element[@name='degree']/doc:element[@name='level']/doc:element/doc:field[@name='value'][1])" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$lc_degree_level = 'doctorado'">doctoralThesis</xsl:when>
					<xsl:when test="$lc_degree_level = 'maestría' or $lc_degree_level = 'maestria' or $lc_degree_level = 'especialidad'">masterThesis</xsl:when>
					<xsl:when test="$lc_degree_level = 'licenciatura'">bachelorThesis</xsl:when>
					<xsl:otherwise>other</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains('|artículo|articulo|artículo de revista|articulo de revista|artículo de investigación|articulo de investigacion|article|journal article|journalarticle|research article|review article|', concat('|', $lc_value, '|'))">article</xsl:when>
			<xsl:when test="contains('|libro|monografía|monografia|book|', concat('|', $lc_value, '|'))">book</xsl:when>
			<xsl:when test="contains('|capítulo de libro|capitulo de libro|book part|bookpart|', concat('|', $lc_value, '|'))">bookPart</xsl:when>
			<xsl:when test="contains('|reseña|resena|review|book review|bookreview|', concat('|', $lc_value, '|'))">review</xsl:when>
			<xsl:when test="contains('|ponencia|memoria de congreso|póster académico|poster académico|poster academico|conference object|conferenceobject|conference paper|conference poster|conference proceedings|', concat('|', $lc_value, '|'))">conferenceObject</xsl:when>
			<xsl:when test="contains('|documento de trabajo|working paper|workingpaper|', concat('|', $lc_value, '|'))">workingPaper</xsl:when>
			<xsl:when test="$lc_value = 'preprint'">preprint</xsl:when>
			<xsl:when test="contains('|reporte técnico|reporte tecnico|estudio de caso|report|technical report|research report|', concat('|', $lc_value, '|'))">report</xsl:when>
			<xsl:when test="contains('|material didáctico|material didactico|lecture|', concat('|', $lc_value, '|'))">lecture</xsl:when>
			<xsl:when test="contains('|bachelor thesis|bachelorthesis|', concat('|', $lc_value, '|'))">bachelorThesis</xsl:when>
			<xsl:when test="contains('|master thesis|masterthesis|', concat('|', $lc_value, '|'))">masterThesis</xsl:when>
			<xsl:when test="contains('|doctoral thesis|doctoralthesis|', concat('|', $lc_value, '|'))">doctoralThesis</xsl:when>
			<xsl:when test="$lc_value = 'annotation'">annotation</xsl:when>
			<xsl:when test="$lc_value = 'patent'">patent</xsl:when>
			<xsl:when test="contains('|contribution to periodical|contributiontoperiodical|contribution to journal|', concat('|', $lc_value, '|'))">contributionToPeriodical</xsl:when>
			<!-- Conjunto de datos, Base de datos, Proyecto, Normativa, Imagen, Mapa, Audio, Vídeo, Otro -->
			<xsl:otherwise>other</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Versión (lista openaire_version_types o término DRIVER) al término DRIVER -->
	<xsl:template name="resolveDriverVersion">
		<xsl:param name="field" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="normalizeVocabularyValue">
				<xsl:with-param name="value" select="$field" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains('|versión publicada|version publicada|publishedversion|vor|', concat('|', $lc_value, '|'))">publishedVersion</xsl:when>
			<xsl:when test="contains('|versión aceptada|version aceptada|acceptedversion|am|', concat('|', $lc_value, '|'))">acceptedVersion</xsl:when>
			<xsl:when test="contains('|versión enviada|version enviada|submittedversion|smur|', concat('|', $lc_value, '|'))">submittedVersion</xsl:when>
			<xsl:when test="contains('|borrador|draft|ao|', concat('|', $lc_value, '|'))">draft</xsl:when>
			<xsl:when test="contains('|versión actualizada|version actualizada|updatedversion|cvor|evor|', concat('|', $lc_value, '|'))">updatedVersion</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Idioma (lista common_iso_languages o código ISO 639-1/639-3) a ISO 639-3.
	     Devuelve vacío para "Otro"; otros códigos de tres letras se conservan. -->
	<xsl:template name="resolveLanguageCode">
		<xsl:param name="value" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="lowercase">
				<xsl:with-param name="value" select="normalize-space($value)" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains('|español|espanol|spanish|es|es_mx|es_es|spa|', concat('|', $lc_value, '|'))">spa</xsl:when>
			<xsl:when test="contains('|inglés|ingles|english|en|en_us|eng|', concat('|', $lc_value, '|'))">eng</xsl:when>
			<xsl:when test="contains('|portugués|portugues|português|portuguese|pt|pt_br|por|', concat('|', $lc_value, '|'))">por</xsl:when>
			<xsl:when test="contains('|francés|frances|français|french|fr|fra|', concat('|', $lc_value, '|'))">fra</xsl:when>
			<xsl:when test="contains('|alemán|aleman|german|de|deu|', concat('|', $lc_value, '|'))">deu</xsl:when>
			<xsl:when test="contains('|italiano|italian|it|ita|', concat('|', $lc_value, '|'))">ita</xsl:when>
			<!-- Lenguas indígenas de la lista common_iso_languages.
			     Chinanteco, Mazateco, Totonaco y Mixe no tienen código ISO 639-3 general y no se exportan. -->
			<xsl:when test="contains('|mazahua|maz|', concat('|', $lc_value, '|'))">maz</xsl:when>
			<xsl:when test="contains('|otomí|otomi|ots|', concat('|', $lc_value, '|'))">ots</xsl:when>
			<xsl:when test="contains('|náhuatl|nahuatl|nah|', concat('|', $lc_value, '|'))">nah</xsl:when>
			<xsl:when test="contains('|matlatzinca|mat|', concat('|', $lc_value, '|'))">mat</xsl:when>
			<xsl:when test="contains('|tlahuica|ocu|', concat('|', $lc_value, '|'))">ocu</xsl:when>
			<xsl:when test="contains('|maya|yua|', concat('|', $lc_value, '|'))">yua</xsl:when>
			<xsl:when test="contains('|zapoteco|zap|', concat('|', $lc_value, '|'))">zap</xsl:when>
			<xsl:when test="contains('|chocho (chocholteco)|chocho|chocholteco|coz|', concat('|', $lc_value, '|'))">coz</xsl:when>
			<xsl:when test="string-length($lc_value) = 3 and translate($lc_value, 'abcdefghijklmnopqrstuvwxyz', '') = ''">
				<xsl:value-of select="$lc_value" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Público destinatario (lista openaire_audience) al vocabulario de OpenAIRE (en inglés).
	     Devuelve vacío si no se reconoce. -->
	<xsl:template name="resolveAudience">
		<xsl:param name="field" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="lowercase">
				<xsl:with-param name="value" select="normalize-space($field)" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lc_value = 'administradores'">Administrators</xsl:when>
			<xsl:when test="$lc_value = 'beneficiarios y solicitantes de fondos federales'">Federal Funds Recipients and Applicants</xsl:when>
			<xsl:when test="$lc_value = 'bibliotecarios'">Librarians</xsl:when>
			<xsl:when test="$lc_value = 'consejeros'">Counsellors</xsl:when>
			<xsl:when test="$lc_value = 'docentes'">Teachers</xsl:when>
			<xsl:when test="$lc_value = 'grupos comunitarios'">Community Groups</xsl:when>
			<xsl:when test="$lc_value = 'estudiantes'">Students</xsl:when>
			<xsl:when test="$lc_value = 'investigadores'">Researchers</xsl:when>
			<xsl:when test="$lc_value = 'medios de comunicación' or $lc_value = 'medios de comunicacion'">News Media</xsl:when>
			<xsl:when test="$lc_value = 'padres y familias'">Parents and Families</xsl:when>
			<xsl:when test="$lc_value = 'personal de apoyo escolar'">School Support Staff</xsl:when>
			<xsl:when test="$lc_value = 'proveedores de ayuda financiera para estudiantes'">Student Financial Aid Providers</xsl:when>
			<xsl:when test="$lc_value = 'responsables de políticas' or $lc_value = 'responsables de politicas'">Policymakers</xsl:when>
			<xsl:when test="$lc_value = 'otros' or $lc_value = 'público en general' or $lc_value = 'publico en general'">Other</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Formato (lista format_types) a tipo MIME. Los valores que ya son MIME se conservan;
	     los que no tienen equivalente devuelven vacío. -->
	<xsl:template name="resolveMimeType">
		<xsl:param name="value" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="lowercase">
				<xsl:with-param name="value" select="normalize-space($value)" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($lc_value, '/')"><xsl:value-of select="$lc_value" /></xsl:when>
			<xsl:when test="$lc_value = 'pdf'">application/pdf</xsl:when>
			<xsl:when test="$lc_value = 'jpeg' or $lc_value = 'jpg'">image/jpeg</xsl:when>
			<xsl:when test="$lc_value = 'png'">image/png</xsl:when>
			<xsl:when test="$lc_value = 'tiff' or $lc_value = 'geotiff'">image/tiff</xsl:when>
			<xsl:when test="$lc_value = 'mp3'">audio/mpeg</xsl:when>
			<xsl:when test="$lc_value = 'wav'">audio/wav</xsl:when>
			<xsl:when test="$lc_value = 'flac'">audio/flac</xsl:when>
			<xsl:when test="$lc_value = 'aac' or $lc_value = 'm4a'">audio/mp4</xsl:when>
			<xsl:when test="$lc_value = 'mp4'">video/mp4</xsl:when>
			<xsl:when test="$lc_value = 'csv'">text/csv</xsl:when>
			<xsl:when test="$lc_value = 'json'">application/json</xsl:when>
			<xsl:when test="$lc_value = 'sql'">application/sql</xsl:when>
			<xsl:when test="$lc_value = 'zip'">application/zip</xsl:when>
			<xsl:when test="$lc_value = 'xlsx'">application/vnd.openxmlformats-officedocument.spreadsheetml.sheet</xsl:when>
			<xsl:when test="$lc_value = 'pptx'">application/vnd.openxmlformats-officedocument.presentationml.presentation</xsl:when>
			<xsl:when test="$lc_value = 'gltf/glb'">model/gltf-binary</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Quita el resolvedor (https://doi.org/, doi:) y deja el DOI como 10.xxxx/... -->
	<xsl:template name="stripDOIResolver">
		<xsl:param name="value" />
		<xsl:choose>
			<xsl:when test="contains($value, 'doi.org/')"><xsl:value-of select="substring-after($value, 'doi.org/')" /></xsl:when>
			<xsl:when test="starts-with($value, 'doi:')"><xsl:value-of select="substring-after($value, 'doi:')" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$value" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Minúsculas, sin espacios extra y sin el prefijo info:eu-repo/semantics/ -->
	<xsl:template name="normalizeVocabularyValue">
		<xsl:param name="value" />
		<xsl:variable name="lc_value">
			<xsl:call-template name="lowercase">
				<xsl:with-param name="value" select="normalize-space($value)" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="starts-with($lc_value, $driverPrefix)"><xsl:value-of select="substring-after($lc_value, $driverPrefix)" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$lc_value" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lowercase">
		<xsl:param name="value" />
		<xsl:value-of select="translate($value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ', 'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø')" />
	</xsl:template>
</xsl:stylesheet>
