<?xml version="1.0" encoding="UTF-8"?>
<!-- 

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    Developed by paulo-graca
    
    > https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd

 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oaire="http://namespace.openaire.eu/schema/oaire/" xmlns:datacite="http://datacite.org/schema/kernel-4"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:doc="http://www.lyncode.com/xoai"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdf="http://www.w3.org/TR/rdf-concepts/" version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

    <xsl:template match="/">
        <oaire:resource xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://namespace.openaire.eu/schema/oaire/ https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd">

            <!-- datacite:title -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']" mode="datacite"/>
            <!-- datacite:creator -->
            <!-- Lee dc.contributor.author y dc.creator -->
            <xsl:call-template name="creators"/>
            <datacite:contributors>
                <!-- other types of contributors !=  -->
                <xsl:apply-templates
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']"
                    mode="datacite"/>
                <xsl:apply-templates select="//doc:metadata/doc:element[@name='repository']"
                    mode="contributor"/>
            </datacite:contributors>
            <!-- oaire:fundingRefence -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']" mode="oaire"/>
            <!-- datacite:relatedIdentifier -->
            <!-- Incluye dc.source.issn y se omite el contenedor si queda vacío -->
            <xsl:call-template name="relatedIdentifiers"/>
            <!-- datacite:alternateIdentifier -->
            <!-- dc.identifier.uri adicionales y dc.identifier.doi -->
            <xsl:call-template name="alternateIdentifiers"/>
            <!-- datacite:dates and embargo -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']" mode="datacite"/>
            <!-- dc:language -->
            <!-- dc.language.iso y dc.language (etiqueta en español) a ISO 639-3 -->
            <xsl:call-template name="languages"/>
            <!-- dc:publisher -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']" mode="dc"/>
            <!-- oaire:resourceType -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']" mode="oaire"/>
            <!-- dc:description -->
            <!-- también dc.description.tableofcontents, dc.description.notes y dc.abstract -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract' or @name='tableofcontents' or @name='notes']"
                mode="dc"/>
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='abstract']"
                mode="dc"/>
            <!-- dc:format -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']" mode="dc"/>
            <!-- datacite:identifier -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']"
                mode="datacite"/>
            <!-- datacite:rights -->
            <!-- dc.rights.accesslevel tiene prioridad; si falta, se usa el
                 comportamiento original (access status y dc.rights) -->
            <xsl:call-template name="accessRights"/>
            <!-- dc:source -->
            <!-- cita bibliográfica de la fuente (dc.bibliographicCitation) -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='bibliographicCitation']/doc:element/doc:field[@name='value']"
                mode="dc_source"/>
            <!-- datacite:subject -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']" mode="datacite"/>
            <!-- oaire:licenseCondition -->
            <!-- dcterms.license y dcterms.license.uri; si faltan, licencia CC de DSpace -->
            <xsl:call-template name="licenseCondition"/>
            <!-- dc:coverage -->
            <!-- dc.coverage.* (countryfocus, other, temporal, spatial) -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']//doc:field[@name='value']">
                <dc:coverage>
                    <xsl:value-of select="."/>
                </dc:coverage>
            </xsl:for-each>
            <!-- datacite:size -->
            <!-- páginas (dc.description.pages) y tamaño de los archivos del bundle ORIGINAL -->
            <xsl:call-template name="sizes"/>
            <!-- oaire:version -->
            <!-- dc.type.publicationversion a COAR Version Types -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='publicationversion']/doc:element/doc:field[@name='value'][1]"
                mode="oaire_version"/>
            <!-- oaire:file -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']" mode="oaire"/>
            <!-- oaire:citation* -->
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='oaire']/doc:element[@name='citation']" mode="oaire"/>
            <!-- dc.source.journal, dc.source.volume y dc.source.elocator cuando no hay oaire.citation.* -->
            <xsl:call-template name="citationFromSource"/>
            <!-- dcterms:audience -->
            <!-- dc.audience (lista openaire_audience) al vocabulario en inglés de OpenAIRE -->
            <xsl:call-template name="audiences"/>
        </oaire:resource>
    </xsl:template>


   <!-- datacite.titles -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_title.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='title']" mode="datacite">
        <datacite:titles>
            <xsl:apply-templates select="." mode="title"/>
        </datacite:titles>
    </xsl:template>

   <!-- datacite.title -->
    <xsl:template match="doc:element[@name='title']" mode="title">
        <!-- datacite.title -->
        <xsl:for-each select="./doc:element/doc:field[@name='value']">
            <datacite:title>
                <xsl:call-template name="xmlLanguage">
                    <xsl:with-param name="name" select="../@name"/>
                </xsl:call-template>
                <xsl:value-of select="."/>
            </datacite:title>
        </xsl:for-each>
         <!-- datacite.title.* -->
        <xsl:for-each select="./doc:element/doc:element/doc:field[@name='value']">
            <datacite:title>
                <xsl:call-template name="xmlLanguage">
                    <xsl:with-param name="name" select="../@name"/>
                </xsl:call-template>
                <xsl:attribute name="titleType">
                    <xsl:call-template name="getTitleType">
                         <xsl:with-param name="elementName" select="../../@name"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </datacite:title>
        </xsl:for-each>
    </xsl:template>


    <!-- datacite.creators -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_creator.html -->
    <!-- Los autores se catalogan en dc.creator (texto libre o virtual por la
         relación isAuthorOfPublication); también se mantiene dc.contributor.author -->
    <xsl:template name="creators">
        <xsl:variable name="authors"
            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']
                  | doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']"/>
        <xsl:if test="$authors">
        <datacite:creators>
            <!-- datacite.creator -->
            <xsl:for-each select="$authors">
                <xsl:variable name="isRelatedEntity">
                    <xsl:call-template name="isRelatedEntity">
                        <xsl:with-param name="element" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <!-- if next sibling is authority and starts with virtual:: -->
                    <xsl:when test="$isRelatedEntity = 'true'">
                        <xsl:variable name="entity">
                            <xsl:call-template name="buildEntityNode">
                                <xsl:with-param name="element" select="."/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:apply-templates select="$entity" mode="entity_creator"/>
                    </xsl:when>
                    <!-- simple text metadata -->
                    <xsl:otherwise>
                        <datacite:creator>
                            <datacite:creatorName>
                                <xsl:value-of select="./text()"/>
                            </datacite:creatorName>
                        </datacite:creator>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </datacite:creators>
        </xsl:if>
    </xsl:template>

    <!-- datacite:creator -->
    <xsl:template match="doc:element" mode="entity_creator">
        <xsl:variable name="isOrgUnitEntity">
            <xsl:call-template name="hasOrganizationLegalNameField">
                <xsl:with-param name="element" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <datacite:creator>
            <datacite:creatorName>
                <!-- determining which name type to use Organizational/Personal -->
                <xsl:attribute name="nameType">
                    <xsl:choose>
                        <xsl:when test="$isOrgUnitEntity = 'true'">
                            <xsl:text>Organizational</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Personal</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$isOrgUnitEntity = 'true'">
                        <xsl:value-of select="doc:field[starts-with(@name,'organization.legalName')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- el nombre virtual del autor se genera en dc.creator -->
                        <xsl:value-of select="doc:field[starts-with(@name,'dc.contributor.author') or starts-with(@name,'dc.creator')]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </datacite:creatorName>
            <xsl:apply-templates select="doc:field" mode="entity_author"/>
        </datacite:creator>
    </xsl:template>


    <!-- datacite:contributors -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_contributor.html -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']" mode="datacite">
        <!-- el calificador (advisor, reviewer, editor...) define el contributorType -->
        <xsl:variable name="contributorQualifier" select="@name"/>
        <xsl:for-each select="./doc:element/doc:field[@name='value']">
            <xsl:variable name="isRelatedEntity">
                <xsl:call-template name="isRelatedEntity">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <!-- if next sibling is authority and starts with virtual:: -->
                <xsl:when test="$isRelatedEntity = 'true'">
                    <xsl:variable name="entity">
                        <xsl:call-template name="buildEntityNode">
                            <xsl:with-param name="element" select="."/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:apply-templates select="$entity" mode="entity_contributor">
                        <xsl:with-param name="contributorQualifier" select="$contributorQualifier"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- simple text metadata -->
                <xsl:otherwise>
                    <datacite:contributor>
                        <!-- contributorType is a mandatory attribute for each contributor -->
                        <xsl:attribute name="contributorType">
                            <xsl:call-template name="getContributorType">
                                <xsl:with-param name="elementName" select="$contributorQualifier"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <datacite:contributorName>
                            <xsl:value-of select="./text()"/>
                        </datacite:contributorName>
                    </datacite:contributor>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- datacite:contributor -->
    <xsl:template match="doc:element" mode="entity_contributor">
        <!-- @name de la entidad construida es "virtual::<id>", por eso el
             calificador del campo se recibe como parámetro -->
        <xsl:param name="contributorQualifier" select="./@name"/>
        <xsl:variable name="isOrgUnitEntity">
            <xsl:call-template name="hasOrganizationLegalNameField">
                <xsl:with-param name="element" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <datacite:contributor>
            <!-- contributorType is a mandatory attribute for each contributor -->
            <xsl:attribute name="contributorType">
                <xsl:call-template name="getContributorType">
                    <xsl:with-param name="elementName" select="$contributorQualifier"/>
                </xsl:call-template>
            </xsl:attribute>
            <datacite:contributorName>
                <!-- determining which name type to use Organizational/Personal -->
                <xsl:attribute name="nameType">
                    <xsl:choose>
                        <xsl:when test="$isOrgUnitEntity = 'true'">
                            <xsl:text>Organizational</xsl:text>
                        </xsl:when>
                        <!-- simple text metadata -->
                        <xsl:otherwise>
                            <xsl:text>Personal</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$isOrgUnitEntity = 'true'">
                        <xsl:value-of select="doc:field[starts-with(@name,'organization.legalName')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="doc:field[starts-with(@name,'dc.contributor')]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </datacite:contributorName>
            <xsl:apply-templates select="doc:field" mode="entity_author"/>
        </datacite:contributor>
    </xsl:template>

    <!-- This repository is considered a contributor of this work
        a contributor of type HostingInstitution
      -->
    <xsl:template match="doc:element[@name='repository']" mode="contributor">
        <datacite:contributor contributorType="HostingInstitution">
            <datacite:contributorName nameType="Organizational">
                <xsl:value-of select="./doc:field[@name='name']"/>
            </datacite:contributorName>
            <xsl:variable name="mail" select="./doc:field[@name='mail']"/>
            <xsl:if test="$mail">
                <datacite:nameIdentifier>
                    <xsl:attribute name="nameIdentifierScheme">
                    <xsl:text>e-mail</xsl:text>
                 </xsl:attribute>
                    <xsl:attribute name="schemeURI">
                    <xsl:value-of select="concat('mailto:',$mail)"/>
                 </xsl:attribute>
                    <xsl:value-of select="$mail"/>
                </datacite:nameIdentifier>
            </xsl:if>
        </datacite:contributor>
    </xsl:template>

    <!-- This template will create a type of identifier exclusive for DSpace
         which is a resolver for that record and, at same time, the REST API end point
     -->
    <!-- también para asesor(a) y revisor(a) vinculados como entidad Person -->
    <xsl:template match="doc:field[(starts-with(@name,'relation.isAuthorOfPublication')
                                    or starts-with(@name,'relation.isAdvisorOfPublication')
                                    or starts-with(@name,'relation.isReviewerOfPublication'))
                                   and not(contains(@name,'latestForDiscovery'))]"
        mode="entity_author">
        <xsl:variable name="url">
            <xsl:call-template name="getDSpaceURL"/>
        </xsl:variable>
        <datacite:nameIdentifier nameIdentifierScheme="DSpace" schemeURI="http://dspace.org">
            <xsl:value-of select="concat($url,'/items/',./text())"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:givenName> from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.givenName')]" mode="entity_author">
        <datacite:givenName>
            <xsl:value-of select="./text()"/>
        </datacite:givenName>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:familyName> from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.familyName')]" mode="entity_author">
        <datacite:familyName>
            <xsl:value-of select="./text()"/>
        </datacite:familyName>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:affiliation> from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.affiliation.name')]" mode="entity_author">
        <datacite:affiliation>
            <xsl:value-of select="./text()"/>
        </datacite:affiliation>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.*')]" mode="entity_author">
        <!-- TODO resolve the scheme based on the value -->
        <datacite:nameIdentifier nameIdentifierScheme="" schemeURI="">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type ORCID from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.orcid')]" mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="http://orcid.org">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type Scopus Author ID from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.scopus-author-id')]"
        mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="Scopus Author ID"
            schemeURI="https://www.scopus.com">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type Ciencia ID from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.ciencia-id')]" mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="Ciência ID"
            schemeURI="https://www.ciencia-id.pt">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type Researcher ID from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.rid')]" mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="Researcher ID"
            schemeURI="https://www.webofscience.com">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type Google Scholar ID from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.gsid')]" mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="Google Scholar ID"
            schemeURI="https://scholar.google.com">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type ISNI from a Person built entity -->
    <xsl:template match="doc:field[starts-with(@name,'person.identifier.isni')]" mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="ISNI" schemeURI="http://www.isni.org">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> for an organization from a built entity -->
    <xsl:template match="doc:field[starts-with(@name,'organization.identifier.*')]" mode="entity_author">
        <!-- TODO resolve the scheme based on the value -->
        <datacite:nameIdentifier nameIdentifierScheme="" schemeURI="">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <datacite:nameIdentifier> of type ISNI for an organization from a built entity -->
    <xsl:template match="doc:field[starts-with(@name,'organization.identifier.isni')]" mode="entity_author">
        <datacite:nameIdentifier nameIdentifierScheme="ISNI" schemeURI="http://www.isni.org">
            <xsl:value-of select="./text()"/>
        </datacite:nameIdentifier>
    </xsl:template>


    <!-- oaire:fundingReferences -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_projectid.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='relation']" mode="oaire">
        <!--  se omite el contenedor si no hay proyectos vinculados
             (p. ej. cuando solo existe dc.relation.ispartofseries) -->
        <xsl:variable name="fundingReferences">
            <xsl:for-each select="./doc:element/doc:field[@name='value']">
                <xsl:variable name="isRelatedEntity">
                    <xsl:call-template name="isRelatedEntity">
                        <xsl:with-param name="element" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- if next sibling is authority and starts with virtual:: -->
                <xsl:if test="$isRelatedEntity = 'true'">
                    <xsl:variable name="entity">
                        <xsl:call-template name="buildEntityNode">
                            <xsl:with-param name="element" select="."/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:apply-templates select="$entity" mode="entity_funding"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="normalize-space($fundingReferences) != ''">
            <oaire:fundingReferences>
                <xsl:copy-of select="$fundingReferences"/>
            </oaire:fundingReferences>
        </xsl:if>
    </xsl:template>

    <!-- oaire:fundingReference -->
    <xsl:template match="doc:element" mode="entity_funding">
        <oaire:fundingReference>
            <xsl:apply-templates select="doc:field" mode="entity_funding"/>
        </oaire:fundingReference>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:awardTitle> from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'dc.relation')]" mode="entity_funding">
        <oaire:awardTitle>
            <xsl:value-of select="./text()"/>
        </oaire:awardTitle>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:funderName> from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'project.funder.name')]" mode="entity_funding">
        <oaire:funderName>
            <xsl:value-of select="./text()"/>
        </oaire:funderName>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:funderIdentifier> from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'project.funder.identifier')]" mode="entity_funding">
        <!-- TODO: recognize the type ISNI / GRID / Crossref Funder -->
        <oaire:funderIdentifier funderIdentifierType="Crossref Funder ID">
            <xsl:value-of select="./text()"/>
        </oaire:funderIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:funderIdentifier> from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'project.funder.rorIdentifier')]" mode="entity_funding">
        <oaire:funderIdentifier funderIdentifierType="ROR" schemeURI="http://ror.org/">
            <xsl:value-of select="./text()"/>
        </oaire:funderIdentifier>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:fundingStream> from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'oaire.fundingStream')]" mode="entity_funding">
        <oaire:fundingStream>
            <xsl:value-of select="./text()"/>
        </oaire:fundingStream>
    </xsl:template>

    <!-- This template creates the sub-element <oaire:awardNumber> from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'oaire.awardNumber')]" mode="entity_funding">
        <!-- TODO: get the awarduri from doc:field@name='oaire.awardURI -->
        <oaire:awardNumber>
            <xsl:attribute name="awardURI">
                <xsl:apply-templates select="../doc:field[starts-with(@name,'oaire.awardURI')]"
                mode="entity_funding_param"/>
            </xsl:attribute>
            <xsl:value-of select="./text()"/>
        </oaire:awardNumber>
    </xsl:template>

    <!-- This template creates the property awardURI from a Funded Project built entity -->
    <xsl:template match="doc:field[starts-with(@name,'oaire.awardURI')]" mode="entity_funding_param">
        <xsl:value-of select="./text()"/>
    </xsl:template>

    <!-- datacite:relatedIdentifiers -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_relatedidentifier.html -->
    <!-- Agrega el ISSN de la revista (dc.source.issn) y omite el contenedor si queda vacío -->
    <xsl:template name="relatedIdentifiers">
        <xsl:variable name="relatedIdentifiers">
            <xsl:apply-templates
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element"
                mode="datacite_ids"/>
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
                <xsl:call-template name="relatedIdentifierTemplate">
                    <xsl:with-param name="value" select="text()"/>
                    <xsl:with-param name="relatedIdentifierType" select="'ISSN'"/>
                    <xsl:with-param name="relationType" select="'IsPartOf'"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="normalize-space($relatedIdentifiers) != ''">
            <datacite:relatedIdentifiers>
                <xsl:copy-of select="$relatedIdentifiers"/>
            </datacite:relatedIdentifiers>
        </xsl:if>
    </xsl:template>
        
   <!-- datacite:relatedIdentifier -->
   <!-- handle: dc.identifier.issn -->
    <xsl:template match="doc:element[@name='issn']" mode="datacite_ids">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'ISSN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.ismn -->
    <xsl:template match="doc:element[@name='ismn']" mode="datacite_ids">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value"
                    select="concat('ISMN:',normalize-space(text()))"/>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.govdoc -->
    <xsl:template match="doc:element[@name='govdoc']" mode="datacite_ids">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value"
                    select="concat('govdoc:',normalize-space(text()))"/>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.isbn -->
    <xsl:template match="doc:element[@name='isbn']" mode="datacite_ids">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'ISBN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.sici -->
    <xsl:template match="doc:element[@name='sici']" mode="datacite_ids">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value"
                    select="concat('sici:',normalize-space(text()))"/>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- handle: dc.identifier.other -->
    <xsl:template match="doc:element[@name='other']" mode="datacite_ids">
        <xsl:for-each select=".//doc:field[@name='value']">
            <xsl:call-template name="relatedIdentifierTemplate">
                <xsl:with-param name="value" select="text()"/>
                <xsl:with-param name="relatedIdentifierType" select="'URN'"/>
                <xsl:with-param name="relationType" select="'IsPartOf'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>    

    <!-- handle: dc.identifier.doi -->
    <!-- El DOI identifica al mismo recurso, por eso se exporta como
         datacite:alternateIdentifier (ver plantilla alternateIdentifiers) -->
    <xsl:template match="doc:element[@name='doi']" mode="datacite_ids"/>

    <!-- handle: dc.identifier.* -->
    <xsl:template match="doc:element" mode="datacite_ids"/>
    
    <!-- template for all relatedIdentifier -->
    <xsl:template name="relatedIdentifierTemplate">
        <xsl:param name="value"/>
        <xsl:param name="relatedIdentifierType"/>
        <xsl:param name="relationType"/>
        <datacite:relatedIdentifier>
            <xsl:attribute name="relatedIdentifierType">
                    <xsl:value-of select="$relatedIdentifierType"/>
                </xsl:attribute>
            <xsl:attribute name="relationType">
                    <xsl:value-of select="$relationType"/>
                </xsl:attribute>
            <xsl:value-of select="normalize-space($value)"/>
        </datacite:relatedIdentifier>
    </xsl:template>


   <!--  datacite:identifier  -->
   <!-- In the repository context Resource Identifier will be the Handle or the generated DOI that is present in dc.identifier.uri. -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_resourceidentifier.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']"
        mode="datacite">
        <xsl:variable name="identifierType">
            <!--  only consider the first dc.identifier.uri -->
            <xsl:call-template name="resolveFieldType">
                <xsl:with-param name="field" select="./doc:element[1]/doc:field[@name='value'][1]"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- only process the first element -->
        <datacite:identifier>
            <!--  el XSD de OpenAIRE exige mayúsculas (HANDLE, DOI, URL) -->
            <xsl:attribute name="identifierType">
                <xsl:call-template name="uppercase">
                    <xsl:with-param name="value" select="$identifierType"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="./doc:element[1]/doc:field[@name='value'][1]"/>
        </datacite:identifier>
    </xsl:template>

    <!--  datacite:alternateIdentifiers  -->
    <!--   dc.identifier.uri a partir del segundo valor y dc.identifier.doi (sin el prefijo https://doi.org/) -->
    <xsl:template name="alternateIdentifiers">
        <xsl:variable name="uris"
            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']"/>
        <xsl:variable name="dois"
            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']"/>
        <xsl:if test="count($uris/doc:element/doc:field[@name='value'])>1 or $dois">
            <datacite:alternateIdentifiers>
                <xsl:apply-templates select="$uris" mode="datacite_altid"/>
                <xsl:for-each select="$dois">
                    <datacite:alternateIdentifier alternateIdentifierType="DOI">
                        <xsl:call-template name="stripDOIResolver">
                            <xsl:with-param name="value" select="normalize-space(.)"/>
                        </xsl:call-template>
                    </datacite:alternateIdentifier>
                </xsl:for-each>
            </datacite:alternateIdentifiers>
        </xsl:if>
    </xsl:template>

    <!--  datacite:alternateIdentifier dc.identifier.uri  -->
    <!--  https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_alternativeidentifier.html -->
    <xsl:template match="doc:element[@name='uri']" mode="datacite_altid">
        <xsl:for-each select="./doc:element/doc:field[@name='value']">
        <!-- don't process the first element -->
            <xsl:if test="position()>1">
                <xsl:variable name="identifierType">
                    <xsl:call-template name="resolveFieldType">
                        <xsl:with-param name="field" select="."/>
                    </xsl:call-template>
                </xsl:variable>

                <datacite:alternateIdentifier>
                    <xsl:attribute name="alternateIdentifierType">
                <xsl:value-of select="$identifierType"/>
            </xsl:attribute>
                    <xsl:value-of select="./text()"/>
                </datacite:alternateIdentifier>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

   <!-- datacite:rights -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_accessrights.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']" mode="datacite">
        <xsl:variable name="rightsValue" select="text()"/>
        <xsl:variable name="rightsURI">
            <xsl:call-template name="resolveRightsURI">
                <xsl:with-param name="field" select="$rightsValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lc_rightsValue">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$rightsValue"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- We are checking to ensure that only values ending in "access" can be used as datacite:rights. 
        This is a valid solution as we pre-normalize dc.rights values in openaire4.xsl to end in the term 
        "access" according to COAR Controlled Vocabulary -->
        <xsl:if test="ends-with($lc_rightsValue,'access')">
            <datacite:rights>
                <xsl:if test="$rightsURI">
                    <xsl:attribute name="rightsURI">
                    <xsl:value-of select="$rightsURI"/>
                </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$rightsValue"/>
            </datacite:rights>
        </xsl:if>
    </xsl:template>

    <!--  from Access Status mechanism  -->
    <!-- datacite:rights -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_accessrights.html -->
    <xsl:template match="doc:element[@name='others']/doc:element[@name='access-status']/doc:field[@name='value']" mode="datacite">
        <xsl:variable name="rightsValue">
            <xsl:call-template name="resolveRightsName">
                <xsl:with-param name="field" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="rightsURI">
            <xsl:call-template name="resolveRightsURI">
                <xsl:with-param name="field" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lc_rightsValue">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$rightsValue"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- We are checking to ensure that only values ending in "access" can be used as datacite:rights. 
        This is a valid solution as we pre-normalize dc.rights values in openaire4.xsl to end in the term 
        "access" according to COAR Controlled Vocabulary -->
        <xsl:if test="ends-with($lc_rightsValue,'access')">
            <datacite:rights>
                <xsl:if test="$rightsURI">
                    <xsl:attribute name="rightsURI">
                        <xsl:value-of select="$rightsURI"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$rightsValue"/>
            </datacite:rights>
        </xsl:if>
    </xsl:template>


    <!-- datacite:rights -->
    <!--  OpenAIRE admite una sola ocurrencia. Se usa dc.rights.accesslevel
         (valor catalogado, lista openaire_rights) y, si falta o no se reconoce,
         el comportamiento original: access status y dc.rights. -->
    <xsl:template name="accessRights">
        <xsl:variable name="accessLevelName">
            <xsl:call-template name="resolveCMAccessRight">
                <xsl:with-param name="field"
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='accesslevel']/doc:element/doc:field[@name='value'][1]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$accessLevelName != ''">
                <datacite:rights>
                    <xsl:attribute name="rightsURI">
                        <xsl:call-template name="resolveRightsURI">
                            <xsl:with-param name="field" select="$accessLevelName"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="$accessLevelName"/>
                </datacite:rights>
            </xsl:when>
            <!-- ACCESS RIGHTS from access status mechanism -->
            <xsl:when test="doc:metadata/doc:element[@name='others']/doc:element[@name='access-status']/doc:field[@name='value']">
                <xsl:apply-templates
                    select="doc:metadata/doc:element[@name='others']/doc:element[@name='access-status']" mode="datacite" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']" mode="datacite"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


   <!-- datacite:subjects -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_subject.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='subject']" mode="datacite">
        <datacite:subjects>
            <xsl:for-each select="./doc:element">
                <xsl:apply-templates select="." mode="datacite"/>
            </xsl:for-each>
        </datacite:subjects>
    </xsl:template>

   <!-- datacite:subject -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='subject']/doc:element" mode="datacite">
        <xsl:for-each select="./doc:field[@name='value']">
            <datacite:subject>
                <xsl:value-of select="./text()"/>
            </datacite:subject>
        </xsl:for-each>
    </xsl:template>


    <!-- datacite.dates -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_embargoenddate.html -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publicationdate.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='date']" mode="datacite">
        <datacite:dates>
        <!-- datacite:date (embargo) -->
            <xsl:for-each select="./doc:element">
                <xsl:apply-templates select="." mode="datacite"/>
            </xsl:for-each>
        </datacite:dates>
    </xsl:template>

    <!-- datacite.date @name=issued or @name=accepted -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publicationdate.html -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']"
        mode="datacite">
        <xsl:variable name="dc_date_value" select="doc:element/doc:field[@name='value']/text()"/>
        <datacite:date dateType="Accepted">
            <xsl:value-of select="$dc_date_value"/>
        </datacite:date>
        <!-- 
            datacite.date issued is different from dc.date.issued
            please check - https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publicationdate.html
         -->
        <datacite:date dateType="Issued">
            <xsl:value-of select="$dc_date_value"/>
        </datacite:date>
    </xsl:template> 

    <!-- datacite.date @name=accessioned -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']" mode="datacite"/>

    <!-- datacite.date -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued' and @name!='accepted' and @name!='accessioned']"
        mode="datacite">
        <xsl:variable name="dateType">
            <xsl:call-template name="getDateType">
                <xsl:with-param name="elementName" select="./@name"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- only consider elements with valid date types -->
        <xsl:if test="$dateType != ''">
            <datacite:date>
                <xsl:attribute name="dateType">
                    <xsl:value-of select="$dateType"/>
                </xsl:attribute>
                <xsl:value-of select="./doc:element/doc:field[@name='value']/text()"/>
            </datacite:date>
        </xsl:if>
    </xsl:template>


    <!-- dc:language -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_language.html -->
    <!-- dc.language.iso ya llega en ISO 639-3 desde transformers/openaire4.xsl;
         dc.language (Español, Inglés...) se traduce a ISO 639-3 y no se repite
         si coincide con dc.language.iso. "Otro" no se exporta. -->
    <xsl:template name="languages">
        <xsl:variable name="isoLanguages"
            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']"/>
        <xsl:for-each select="$isoLanguages">
	        <dc:language>
	            <xsl:value-of select="./text()"/>
	        </dc:language>
        </xsl:for-each>
        <xsl:for-each
            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[doc:field[@name='value']]/doc:field[@name='value']">
            <xsl:variable name="languageCode">
                <xsl:call-template name="resolveLanguageCode">
                    <xsl:with-param name="value" select="."/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$languageCode != '' and not($isoLanguages[. = $languageCode])">
                <dc:language>
                    <xsl:value-of select="$languageCode"/>
                </dc:language>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- dc:publisher -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publisher.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='publisher']" mode="dc">
    	<xsl:for-each select="./doc:element/doc:field[@name='value']">
	       <dc:publisher>
	           <xsl:value-of select="./text()"/>
	       </dc:publisher>
        </xsl:for-each>
        <!--  institución que otorga el grado (tesis), si es distinta de dc.publisher -->
        <xsl:variable name="publishers" select="./doc:element/doc:field[@name='value']"/>
        <xsl:for-each select="./doc:element[@name='degree']/doc:element/doc:field[@name='value']">
            <xsl:if test="not($publishers[. = current()])">
                <dc:publisher>
                    <xsl:value-of select="./text()"/>
                </dc:publisher>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- oaire:resourceType -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publicationtype.html -->
    <xsl:template match="doc:element[@name='dc']/doc:element[@name='type']/doc:element[doc:field[@name='value']]" mode="oaire">
        <!--  traduce el tipo en español (lista common_types) a la etiqueta COAR en inglés -->
        <xsl:variable name="resourceTypeLabel">
            <xsl:call-template name="resolveCMResourceType">
                <xsl:with-param name="field" select="./doc:field[@name='value']/text()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="resourceTypeGeneral">
            <xsl:call-template name="resolveResourceTypeGeneral">
                <xsl:with-param name="field" select="$resourceTypeLabel"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="resourceTypeURI">
            <xsl:call-template name="resolveResourceTypeURI">
                <xsl:with-param name="field" select="$resourceTypeLabel"/>
            </xsl:call-template>
        </xsl:variable>
        <oaire:resourceType>
            <xsl:attribute name="resourceTypeGeneral">
                <xsl:value-of select="$resourceTypeGeneral"/>
            </xsl:attribute>
            <xsl:attribute name="uri">
                <xsl:value-of select="$resourceTypeURI"/>
            </xsl:attribute>
            <xsl:value-of select="$resourceTypeLabel"/>
        </oaire:resourceType>
    </xsl:template>


    <!-- dc:description -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_description.html -->
    <!--  incluye tableofcontents, notes y dc.abstract; se exportan todos los
         valores de cada idioma (antes solo se tomaba el primero) -->
    <xsl:template
        match="doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract' or @name='tableofcontents' or @name='notes']/doc:element
             | doc:element[@name='dc']/doc:element[@name='abstract']/doc:element"
        mode="dc">
        <xsl:variable name="lang" select="@name"/>
        <xsl:for-each select="./doc:field[@name='value']">
            <dc:description>
                <xsl:call-template name="xmlLanguage">
                    <xsl:with-param name="name" select="$lang"/>
                </xsl:call-template>
                <xsl:value-of select="."/>
            </dc:description>
        </xsl:for-each>
    </xsl:template>

    <!-- dc:source -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_source.html -->
    <!--  dc.bibliographicCitation -->
    <xsl:template match="doc:field" mode="dc_source">
        <dc:source>
            <xsl:value-of select="normalize-space(.)"/>
        </dc:source>
    </xsl:template>

    <!-- dc:format -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_size.html -->
    <xsl:template match="doc:element[@name='bundles']/doc:element[@name='bundle']" mode="dc">
        <xsl:if test="doc:field[@name='name' and text()='ORIGINAL']">
            <xsl:for-each select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                <xsl:apply-templates select="." mode="dc"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="doc:element[@name='bitstreams']/doc:element[@name='bitstream']" mode="dc">
        <dc:format>
            <xsl:value-of select="doc:field[@name='format']"/>
        </dc:format>
    </xsl:template>


    <!-- datacite:sizes -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_size.html -->
    <!-- Un solo datacite:sizes con la extensión (dc.description.pages: "245" sale como "245 pages";
         si ya trae texto, p. ej. "245 p.", se exporta tal cual) y el tamaño de cada archivo del bundle ORIGINAL.
         No se genera si el ítem no tiene páginas ni archivos. -->
    <xsl:template name="sizes">
        <xsl:variable name="pages"
            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='pages']/doc:element/doc:field[@name='value'][normalize-space(.) != '']"/>
        <xsl:variable name="bitstreams"
            select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle'][doc:field[@name='name']='ORIGINAL']/doc:element[@name='bitstreams']/doc:element[@name='bitstream']"/>
        <xsl:if test="$pages or $bitstreams">
            <datacite:sizes>
                <xsl:for-each select="$pages">
                    <datacite:size>
                        <xsl:choose>
                            <xsl:when test="translate(normalize-space(.), '0123456789', '') = ''">
                                <xsl:value-of select="concat(normalize-space(.), ' pages')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </datacite:size>
                </xsl:for-each>
                <xsl:apply-templates select="$bitstreams" mode="datacite"/>
            </datacite:sizes>
        </xsl:if>
    </xsl:template>
    
     <!-- datacite:size -->
    <xsl:template match="doc:element[@name='bitstreams']/doc:element[@name='bitstream']" mode="datacite">
        <datacite:size>
            <xsl:value-of select="concat(doc:field[@name='size'],' bytes')"/>
        </datacite:size>
    </xsl:template>

   <!-- oaire:file -->
   <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_filelocation.html -->
    <xsl:template match="doc:element[@name='bundles']/doc:element[@name='bundle']" mode="oaire">
       <!-- only consider ORIGINAL bundle -->
        <xsl:if test="doc:field[@name='name' and text()='ORIGINAL']">
            <xsl:for-each select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                <xsl:apply-templates select="." mode="oaire"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- oaire:file -->
    <!-- processing of each bitstream entry -->
    <xsl:template match="doc:element[@name='bitstreams']/doc:element[@name='bitstream']" mode="oaire">
        <oaire:file>
            <xsl:attribute name="accessRightsURI">
                <!-- get the coar access rights at the individual file level -->
                <!-- Look at resource policies to infer access level information, defaults to item-level status -->
                <xsl:choose>
                    <xsl:when test="doc:element[@name='resourcePolicies']/doc:element[doc:field[@name='action']/text()='READ' and doc:field[@name='group']/text()='Anonymous' and doc:field[@name='start-date']]">
                        <xsl:call-template name="resolveRightsURI">
                            <xsl:with-param name="field"
                                            select="'embargo'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="doc:element[@name='resourcePolicies']/doc:element[doc:field[@name='action']/text()='READ' and doc:field[@name='group']/text()='Anonymous' and not(doc:field[@name='start-date'])]">
                        <xsl:call-template name="resolveRightsURI">
                            <xsl:with-param name="field"
                                            select="'open.access'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="doc:element[@name='resourcePolicies']/doc:element[doc:field[@name='action']/text()='READ' and doc:field[@name='group']/text()='Administrator']">
                        <xsl:call-template name="resolveRightsURI">
                            <xsl:with-param name="field"
                                            select="'restricted'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Default to item-level access status information -->
                        <xsl:call-template name="getRightsURI"/>
                    </xsl:otherwise>
                </xsl:choose>
         </xsl:attribute>
            <xsl:attribute name="mimeType">
            <xsl:value-of select="doc:field[@name='format']"/>
         </xsl:attribute>
            <!-- Currently there is no available way to identify the type of the bitstream -->
            <!--<xsl:attribute name="objectType">
            <xsl:choose>
                <xsl:when test="1">
                    <xsl:text>fulltext</xsl:text>
                </xsl:when>
                xsl:when test="$type='dataset'">
                    <xsl:text>dataset</xsl:text>
                </xsl:when>
                <xsl:when test="$type='software'">
                    <xsl:text>software</xsl:text>
                </xsl:when>
                <xsl:when test="$type='article'">
                    <xsl:text>fulltext</xsl:text>
                </xsl:when
                <xsl:otherwise>                  
                    <xsl:text>other</xsl:text>
                </xsl:otherwise>
             </xsl:choose>
           </xsl:attribute>-->
            <xsl:value-of select="doc:field[@name='url']"/>
        </oaire:file>
    </xsl:template>


    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationtitle.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='title']" mode="oaire">
      <!-- citationTitle -->
        <oaire:citationTitle>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationTitle>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationedition.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='edition']" mode="oaire">
      <!-- citationEdition -->
        <oaire:citationEdition>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationEdition>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationvolume.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='volume']" mode="oaire">
      <!-- citationVolume -->
        <oaire:citationVolume>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationVolume>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationissue.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='issue']" mode="oaire">
      <!-- citationVolume -->
        <oaire:citationIssue>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationIssue>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationstartpage.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='startPage']" mode="oaire">
      <!-- citationStartPage -->
        <oaire:citationStartPage>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationStartPage>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationendpage.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='endPage']" mode="oaire">
      <!-- citationEndPage -->
        <oaire:citationEndPage>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationEndPage>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationconferenceplace.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='conferencePlace']"
        mode="oaire">
      <!-- citationConferencePlace -->
        <oaire:citationConferencePlace>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationConferencePlace>
    </xsl:template>

    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_citationconferencedate.html -->
    <xsl:template
        match="doc:element[@name='oaire']/doc:element[@name='citation']/doc:element[@name='conferenceDate']"
        mode="oaire">
      <!-- citationConferenceDate -->
        <oaire:citationConferenceDate>
            <xsl:value-of select="./doc:element/doc:field[@name='value']"/>
        </oaire:citationConferenceDate>
    </xsl:template>

    <!--  datos de la revista desde dc.source.*, solo si no existe el oaire.citation.* equivalente.
         dc.source.elocator (número de artículo electrónico, p. ej. e2370) se exporta como citationStartPage -->
    <xsl:template name="citationFromSource">
        <xsl:variable name="citation" select="doc:metadata/doc:element[@name='oaire']/doc:element[@name='citation']"/>
        <xsl:variable name="source" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']"/>
        <xsl:if test="not($citation/doc:element[@name='title'])">
            <xsl:for-each select="$source/doc:element[@name='journal']/doc:element/doc:field[@name='value'][1]">
                <oaire:citationTitle>
                    <xsl:value-of select="."/>
                </oaire:citationTitle>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="not($citation/doc:element[@name='volume'])">
            <xsl:for-each select="$source/doc:element[@name='volume']/doc:element/doc:field[@name='value'][1]">
                <oaire:citationVolume>
                    <xsl:value-of select="."/>
                </oaire:citationVolume>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="not($citation/doc:element[@name='startPage'])">
            <xsl:for-each select="$source/doc:element[@name='elocator']/doc:element/doc:field[@name='value'][1]">
                <oaire:citationStartPage>
                    <xsl:value-of select="."/>
                </oaire:citationStartPage>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- oaire:version -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_version.html -->
    <!--  dc.type.publicationversion (lista openaire_version_types) a COAR Version Types -->
    <xsl:template match="doc:field" mode="oaire_version">
        <xsl:variable name="versionLabel">
            <xsl:call-template name="resolveVersionLabel">
                <xsl:with-param name="field" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$versionLabel != ''">
            <oaire:version>
                <xsl:attribute name="uri">
                    <xsl:call-template name="resolveVersionURI">
                        <xsl:with-param name="label" select="$versionLabel"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:value-of select="$versionLabel"/>
            </oaire:version>
        </xsl:if>
    </xsl:template>

    <!-- dcterms:audience -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_audience.html -->
    <!--  dc.audience (lista openaire_audience) al vocabulario en inglés; sin repetidos -->
    <xsl:template name="audiences">
        <xsl:variable name="audiences">
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='audience']/doc:element/doc:field[@name='value']">
                <audience>
                    <xsl:call-template name="resolveAudience">
                        <xsl:with-param name="field" select="."/>
                    </xsl:call-template>
                </audience>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$audiences/audience[. != '' and not(. = preceding-sibling::audience)]">
            <dcterms:audience>
                <xsl:value-of select="."/>
            </dcterms:audience>
        </xsl:for-each>
    </xsl:template>



   <!--  -->
   <!-- Auxiliary templates - get types -->
   <!--  -->

    <!-- This template will retrieve the type of a title element (like: alternative) based on the element name -->
    <xsl:template name="getTitleType">
        <xsl:param name="elementName"/>
        <xsl:variable name="lc_title_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$elementName"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_title_type = 'alternativetitle' or $lc_title_type = 'alternative'">
                <xsl:text>AlternativeTitle</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_title_type = 'subtitle'">
                <xsl:text>Subtitle</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_title_type = 'translatedtitle'">
                <xsl:text>TranslatedTitle</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- This template will retrieve the type of a contributor based on the element name -->
    <xsl:template name="getContributorType">
        <xsl:param name="elementName"/>
        <xsl:variable name="lc_contributor_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$elementName"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_contributor_type = 'advisor' or $lc_contributor_type = 'supervisor'">
                <xsl:text>Supervisor</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_contributor_type = 'editor'">
                <xsl:text>Editor</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Other</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- This template will retrieve the type of a date based on the element name -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/vocab_datetype.html -->
    <!-- Accepted and Issued date types are handled separately above. -->
    <xsl:template name="getDateType">
        <xsl:param name="elementName"/>
        <xsl:variable name="lc_dc_date_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$elementName"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_dc_date_type = 'embargo'">
                <!-- Indicates the end of the embargo period. -->
                <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_embargoenddate.html -->
                <xsl:text>Available</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- This template will retrieve the identifier type based on the element name -->
    <!-- 
        there are some special cases like DOI or HANDLE which the type is also
        inferred from the value itself
      -->
    <xsl:template name="getRelatedIdentifierType">
        <xsl:param name="element"/>
        <xsl:variable name="lc_identifier_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$element/@name"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isHandle">
            <xsl:call-template name="isHandle">
                <xsl:with-param name="field" select="$element/doc:field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isDOI">
            <xsl:call-template name="isDOI">
                <xsl:with-param name="field" select="$element/doc:field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isURL">
            <xsl:call-template name="isURL">
                <xsl:with-param name="field" select="$element/doc:field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_identifier_type = 'ark'">
                <xsl:text>ARK</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'arxiv'">
                <xsl:text>arXiv</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'bibcode'">
                <xsl:text>bibcode</xsl:text>
            </xsl:when>
            <xsl:when test="$isDOI = 'true' or $lc_identifier_type = 'doi'">
                <xsl:text>DOI</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'ean13'">
                <xsl:text>EAN13</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'eissn'">
                <xsl:text>EISSN</xsl:text>
            </xsl:when>
            <xsl:when test="$isHandle = 'true' or $lc_identifier_type = 'handle'">
                <xsl:text>Handle</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'igsn'">
                <xsl:text>IGSN</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'isbn'">
                <xsl:text>ISBN</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'issn'">
                <xsl:text>ISSN</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'istc'">
                <xsl:text>ISTC</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'lissn'">
                <xsl:text>LISSN</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'lsid'">
                <xsl:text>LSID</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'pmid'">
                <xsl:text>PMID</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'purl'">
                <xsl:text>PURL</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_identifier_type = 'upc'">
                <xsl:text>UPC</xsl:text>
            </xsl:when>
            <xsl:when test="$isURL = 'true' or $lc_identifier_type = 'url'">
                <xsl:text>URL</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>URN</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



   <!--  -->
   <!-- Auxiliary templates - get global values -->
   <!--  -->
   
    <!-- get the coar access rights globally from access status mechanism -->
    <xsl:template name="getRightsURI">
        <xsl:call-template name="resolveRightsURI">
            <xsl:with-param name="field"
                select="/doc:metadata/doc:element[@name='others']/doc:element[@name='access-status']/doc:field[@name='value']/text()"/>
        </xsl:call-template>
    </xsl:template>

   <!-- get the issued date globally -->
    <xsl:template name="getIssuedDate">
        <xsl:value-of
            select="//doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"/>
    </xsl:template>

   <!-- get the repository baseUrl globally -->
   <!--  se toma de una variable global porque dentro de una entidad construida
        (buildEntityNode) "//" apunta a esa entidad y la URL quedaba vacía -->
    <xsl:variable name="dspaceURL"
        select="/doc:metadata/doc:element[@name='repository']/doc:field[@name='url']/text()"/>
    <xsl:template name="getDSpaceURL">
        <xsl:value-of select="$dspaceURL"/>
    </xsl:template>

   <!--  -->
   <!-- Auxiliary templates - dealing with Entities -->
   <!--  -->

    <!-- 
        this template will verify if a field name with "authority"
        is present and if it start with "virtual::"
        if it occurs, than we are in a presence of a related entity 
     -->
    <xsl:template name="isRelatedEntity">
        <xsl:param name="element"/>
        <xsl:variable name="sibling1" select="$element/following-sibling::*[1]"/>
        <!-- if next sibling is authority and starts with virtual:: -->
        <xsl:choose>
            <xsl:when test="$sibling1[@name='authority' and starts-with(text(),'virtual::')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
        this template will try to look for all "virtual::"
        and rebuild an "Entity" based on all virtual fields 
        in the source data.
        This will retrieve something like:
        <element name="virtual::226">
           <field name="dc.contributor.author.none">Doe, John</field>
           <field name="person.givenName.none">John</field>
           <field name="person.familyName.none">Doe</field>
           <field name="relation.isAuthorOfPublication.none">3f685bbd-07d9-403e-9de2-b8f0fabe27a7</field>
        </element>
     -->
    <xsl:template name="buildEntityNode">
        <xsl:param name="element"/>
        <!-- authority? -->
        <xsl:variable name="sibling1" select="$element/following-sibling::*[1]"/>
        <!-- confidence? -->
        <xsl:variable name="sibling2" select="$element/following-sibling::*[2]"/>
        <!-- if next sibling is authority and starts with virtual:: -->
        <xsl:if test="$sibling1[@name='authority' and starts-with(text(),'virtual::')]">
            <xsl:variable name="relation_id" select="$sibling1[1]/text()"/>
            <xsl:element name="element" namespace="http://www.lyncode.com/xoai">
                <xsl:attribute name="name">
                    <xsl:value-of select="$relation_id"/>
                </xsl:attribute>
                <!-- search for all virtual relations elements in XML -->
                <xsl:for-each select="//doc:field[text()=$relation_id]/preceding-sibling::*[1]">
                    <xsl:element name="field" namespace="http://www.lyncode.com/xoai">
                        <xsl:attribute name="name">
                        <xsl:call-template name="buildEntityFieldName">
                        <xsl:with-param name="element" select="."/>
                          </xsl:call-template>
                        </xsl:attribute>
                        <!-- field value -->
                        <xsl:value-of select="./text()"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>

   <!-- 
        This template will recursively create the field name based on parent node names
        to be something like this:
        person.familyName.*
    -->
    <xsl:template name="buildEntityFieldName">
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="$element/..">
                <xsl:call-template name="buildEntityFieldName">
                    <xsl:with-param name="element" select="$element/.."/>
                </xsl:call-template>
                <!-- if parent isn't an element then don't include '.' -->
                <xsl:if test="local-name($element/../..) = 'element'">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:value-of select="$element/../@name"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

   <!--  -->
   <!-- Other Auxiliary templates -->
   <!--  -->
    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyzàèìòùáéíóúýâêîôûãñõäëïöüÿåæœçðø'"/>
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÈÌÒÙÁÉÍÓÚÝÂÊÎÔÛÃÑÕÄËÏÖÜŸÅÆŒÇÐØ'"/>

   <!-- to retrieve a string in uppercase -->
    <xsl:template name="uppercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $smallcase, $uppercase)"/>
    </xsl:template>

   <!-- to retrieve a string in lowercase -->
    <xsl:template name="lowercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $uppercase, $smallcase)"/>
    </xsl:template>

    <!-- to retrieve a string which the first letter is in uppercase -->
    <xsl:template name="ucfirst">
        <xsl:param name="value"/>
        <xsl:call-template name="uppercase">
            <xsl:with-param name="value" select="substring($value, 1, 1)"/>
        </xsl:call-template>
        <xsl:call-template name="lowercase">
            <xsl:with-param name="value" select="substring($value, 2)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- 
        this template will verify if an element
        has any field that has the name starting "organization.legalName"
     -->
    <xsl:template name="hasOrganizationLegalNameField">
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="$element/doc:field[starts-with(@name,'organization.legalName')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- it will verify if a given field is an handle -->
    <xsl:template name="isHandle">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="$field[contains(text(),'hdl.handle.net')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- it will verify if a given field is a DOI -->
    <xsl:template name="isDOI">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="$field[contains(text(),'doi.org') or starts-with(text(),'10.')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- it will verify if a given field is an ORCID -->
    <xsl:template name="isORCID">
        <xsl:param name="field"/>
        <xsl:choose>
            <xsl:when test="$field[contains(text(),'orcid.org')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- it will verify if a given field is an URL -->
    <xsl:template name="isURL">
        <xsl:param name="field"/>
        <xsl:variable name="lc_field">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_field[starts-with(text(),'http://') or starts-with(text(),'https://')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- will try to resolve the field type based on the value -->
    <xsl:template name="resolveFieldType">
        <xsl:param name="field"/>
        <!-- regexp not supported on XSLTv1 -->
        <xsl:variable name="isHandle">
            <xsl:call-template name="isHandle">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isDOI">
            <xsl:call-template name="isDOI">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isURL">
            <xsl:call-template name="isURL">
                <xsl:with-param name="field" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$isHandle = 'true'">
                <xsl:text>Handle</xsl:text>
            </xsl:when>
            <xsl:when test="$isDOI = 'true'">
                <xsl:text>DOI</xsl:text>
            </xsl:when>
            <xsl:when test="$isURL = 'true' and $isHandle = 'false' and $isDOI = 'false'">
                <xsl:text>URL</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N/A</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        This template will return the general type of the resource
        based on a valued text like 'article'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publicationtype.html#attribute-resourcetypegeneral-m
     -->
    <xsl:template name="resolveResourceTypeGeneral">
        <xsl:param name="field"/>
        <xsl:variable name="lc_dc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <!--  se amplía la lista de tipos textuales (antes solo artículos, libros y tesis) -->
            <xsl:when test="contains('|article|journal article|research article|review article|editorial|letter|letter to the editor|contribution to journal|data paper|book|book part|book review|review|bachelor thesis|doctoral thesis|master thesis|thesis|conference proceedings|conference object|conference paper|conference poster|conference paper not in proceedings|conference poster not in proceedings|lecture|preprint|working paper|report|report part|research report|technical report|internal report|memorandum|other type of report|policy report|project deliverable|report to funding agency|research proposal|technical documentation|bibliography|annotation|text|journal|periodical|', concat('|',$lc_dc_type,'|'))">
                <xsl:text>literature</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'dataset'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'software'">
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>other research product</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        This template will return the COAR Resource Type Vocabulary URI
        like http://purl.org/coar/resource_type/c_6501
        based on a valued text like 'article'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_publicationtype.html#attribute-uri-m
     -->
    <xsl:template name="resolveResourceTypeURI">
        <xsl:param name="field"/>
        <xsl:variable name="lc_dc_type">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_dc_type = 'annotation'">
                <xsl:text>http://purl.org/coar/resource_type/c_1162</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal'">
                <xsl:text>http://purl.org/coar/resource_type/c_0640</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'article'">
                <xsl:text>http://purl.org/coar/resource_type/c_6501</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'journal article'">
                <xsl:text>http://purl.org/coar/resource_type/c_6501</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'editorial'">
                <xsl:text>http://purl.org/coar/resource_type/c_b239</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'bachelor thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_7a1f</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'bibliography'">
                <xsl:text>http://purl.org/coar/resource_type/c_86bc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book'">
                <xsl:text>http://purl.org/coar/resource_type/c_2f33</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book part'">
                <xsl:text>http://purl.org/coar/resource_type/c_3248</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'book review'">
                <xsl:text>http://purl.org/coar/resource_type/c_ba08</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'website'">
                <xsl:text>http://purl.org/coar/resource_type/c_7ad9</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'interactive resource'">
                <xsl:text>http://purl.org/coar/resource_type/c_e9a0</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference proceedings'">
                <xsl:text>http://purl.org/coar/resource_type/c_f744</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference object'">
                <xsl:text>http://purl.org/coar/resource_type/c_c94f</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference paper'">
                <xsl:text>http://purl.org/coar/resource_type/c_5794</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference poster'">
                <xsl:text>http://purl.org/coar/resource_type/c_6670</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'contribution to journal'">
                <xsl:text>http://purl.org/coar/resource_type/c_3e5a</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'data paper'">
                <xsl:text>http://purl.org/coar/resource_type/c_beb9</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'dataset'">
                <xsl:text>http://purl.org/coar/resource_type/c_ddb1</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'doctoral thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_db06</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'image'">
                <xsl:text>http://purl.org/coar/resource_type/c_c513</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'lecture'">
                <xsl:text>http://purl.org/coar/resource_type/c_8544</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'letter'">
                <xsl:text>http://purl.org/coar/resource_type/c_0857</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'master thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_bdcc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'moving image'">
                <xsl:text>http://purl.org/coar/resource_type/c_8a7e</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'periodical'">
                <xsl:text>http://purl.org/coar/resource_type/c_2659</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'letter to the editor'">
                <xsl:text>http://purl.org/coar/resource_type/c_545b</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'patent'">
                <xsl:text>http://purl.org/coar/resource_type/c_15cd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'preprint'">
                <xsl:text>http://purl.org/coar/resource_type/c_816b</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report'">
                <xsl:text>http://purl.org/coar/resource_type/c_93fc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report part'">
                <xsl:text>http://purl.org/coar/resource_type/c_ba1f</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'research proposal'">
                <xsl:text>http://purl.org/coar/resource_type/c_baaf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'review'">
                <xsl:text>http://purl.org/coar/resource_type/c_efa0</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'software'">
                <xsl:text>http://purl.org/coar/resource_type/c_5ce6</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'still image'">
                <xsl:text>http://purl.org/coar/resource_type/c_ecc8</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'technical documentation'">
                <xsl:text>http://purl.org/coar/resource_type/c_71bd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'workflow'">
                <xsl:text>http://purl.org/coar/resource_type/c_393c</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'working paper'">
                <xsl:text>http://purl.org/coar/resource_type/c_8042</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'thesis'">
                <xsl:text>http://purl.org/coar/resource_type/c_46ec</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'cartographic material'">
                <xsl:text>http://purl.org/coar/resource_type/c_12cc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'map'">
                <xsl:text>http://purl.org/coar/resource_type/c_12cd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'video'">
                <xsl:text>http://purl.org/coar/resource_type/c_12ce</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'sound'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'musical composition'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cd</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'text'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference paper not in proceedings'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cp</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'conference poster not in proceedings'">
                <xsl:text>http://purl.org/coar/resource_type/c_18co</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'musical notation'">
                <xsl:text>http://purl.org/coar/resource_type/c_18cw</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'internal report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18ww</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'memorandum'">
                <xsl:text>http://purl.org/coar/resource_type/c_18wz</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'other type of report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18wq</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'policy report'">
                <xsl:text>http://purl.org/coar/resource_type/c_186u</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'project deliverable'">
                <xsl:text>http://purl.org/coar/resource_type/c_18op</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'report to funding agency'">
                <xsl:text>http://purl.org/coar/resource_type/c_18hj</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'research report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18ws</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'technical report'">
                <xsl:text>http://purl.org/coar/resource_type/c_18gh</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'review article'">
                <xsl:text>http://purl.org/coar/resource_type/c_dcae04bc</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_dc_type = 'research article'">
                <xsl:text>http://purl.org/coar/resource_type/c_2df8fbb1</xsl:text>
            </xsl:when>
            <!--  Material didáctico -->
            <xsl:when test="$lc_dc_type = 'learning object'">
                <xsl:text>http://purl.org/coar/resource_type/c_e059</xsl:text>
            </xsl:when>
            <!-- other -->
            <xsl:otherwise>
                <xsl:text>http://purl.org/coar/resource_type/c_1843</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        This template will return the COAR Access Right Vocabulary Names in English
        like "open access"
        based on the values from DSpace Access Status mechanism like String 'open.access'
        please check class org.dspace.access.status.DefaultAccessStatusHelper for more information
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_accessrights.html#definition-and-usage-instruction
     -->
    <xsl:template name="resolveRightsName">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'open.access'">
                <xsl:text>open access</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'embargo'">
                <xsl:text>embargoed access</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'restricted'">
                <xsl:text>restricted access</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'metadata.only'">
                <xsl:text>metadata only access</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!--
        This template will return the COAR Access Right Vocabulary URI
        like http://purl.org/coar/access_right/c_abf2
        based on a value text like 'open access'
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_accessrights.html#definition-and-usage-instruction
     -->
    <xsl:template name="resolveRightsURI">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$field"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'open access' or $lc_value = 'open.access'">
                <xsl:text>http://purl.org/coar/access_right/c_abf2</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'embargoed access' or $lc_value = 'embargo'">
                <xsl:text>http://purl.org/coar/access_right/c_f1cf</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'restricted access' or $lc_value = 'restricted'">
                <xsl:text>http://purl.org/coar/access_right/c_16ec</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'metadata only access' or $lc_value = 'metadata.only'">
                <xsl:text>http://purl.org/coar/access_right/c_14cb</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

   <!--  -->
   <!-- vocabularios de las plantillas de catalogación (submission-forms.xml) -->
   <!--  -->

    <!--
        dc.type (lista common_types, en español) a la etiqueta COAR Resource Types en inglés.
        La tesis se precisa con cm.degree.level (Doctorado, Maestría, Licenciatura).
        Los valores que no están en la lista (p. ej. etiquetas en inglés) se devuelven
        tal cual para que los resuelvan resolveResourceTypeGeneral y resolveResourceTypeURI.
     -->
    <xsl:template name="resolveCMResourceType">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="normalize-space($field)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'tesis'">
                <xsl:variable name="lc_degree_level">
                    <xsl:call-template name="lowercase">
                        <xsl:with-param name="value"
                            select="normalize-space(/doc:metadata/doc:element[@name='cm']/doc:element[@name='degree']/doc:element[@name='level']/doc:element/doc:field[@name='value'][1])"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$lc_degree_level = 'doctorado'">
                        <xsl:text>doctoral thesis</xsl:text>
                    </xsl:when>
                    <xsl:when test="$lc_degree_level = 'maestría' or $lc_degree_level = 'maestria'">
                        <xsl:text>master thesis</xsl:text>
                    </xsl:when>
                    <xsl:when test="$lc_degree_level = 'licenciatura'">
                        <xsl:text>bachelor thesis</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>thesis</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lc_value = 'artículo' or $lc_value = 'articulo' or $lc_value = 'artículo de revista' or $lc_value = 'articulo de revista'">
                <xsl:text>journal article</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'artículo de investigación' or $lc_value = 'articulo de investigacion'">
                <xsl:text>research article</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'audio'">
                <xsl:text>sound</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'base de datos' or $lc_value = 'conjunto de datos'">
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'capítulo de libro' or $lc_value = 'capitulo de libro'">
                <xsl:text>book part</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'documento de trabajo'">
                <xsl:text>working paper</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'estudio de caso'">
                <xsl:text>research report</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'imagen'">
                <xsl:text>image</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'normativa y documento institucional'">
                <xsl:text>text</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'libro' or $lc_value = 'monografía' or $lc_value = 'monografia'">
                <xsl:text>book</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'mapa'">
                <xsl:text>map</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'material didáctico' or $lc_value = 'material didactico'">
                <xsl:text>learning object</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'memoria de congreso'">
                <xsl:text>conference proceedings</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'ponencia'">
                <xsl:text>conference paper</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'póster académico' or $lc_value = 'poster académico' or $lc_value = 'poster academico'">
                <xsl:text>conference poster</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'preprint'">
                <xsl:text>preprint</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'proyecto'">
                <xsl:text>research proposal</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'reporte técnico' or $lc_value = 'reporte tecnico'">
                <xsl:text>technical report</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'reseña' or $lc_value = 'resena'">
                <xsl:text>review</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'vídeo' or $lc_value = 'video'">
                <xsl:text>video</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'otro'">
                <xsl:text>other</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lc_value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        dc.language (lista common_iso_languages: Español, Inglés, Otro) a ISO 639-3.
        También acepta códigos ISO 639-1/639-3. Devuelve vacío para "Otro" y valores desconocidos.
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_language.html
     -->
    <xsl:template name="resolveLanguageCode">
        <xsl:param name="value"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="normalize-space($value)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'español' or $lc_value = 'espanol' or $lc_value = 'spanish' or $lc_value = 'es' or $lc_value = 'spa'">
                <xsl:text>spa</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'inglés' or $lc_value = 'ingles' or $lc_value = 'english' or $lc_value = 'en' or $lc_value = 'eng'">
                <xsl:text>eng</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'portugués' or $lc_value = 'portugues' or $lc_value = 'português' or $lc_value = 'portuguese' or $lc_value = 'pt' or $lc_value = 'por'">
                <xsl:text>por</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'francés' or $lc_value = 'frances' or $lc_value = 'français' or $lc_value = 'french' or $lc_value = 'fr' or $lc_value = 'fra'">
                <xsl:text>fra</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'alemán' or $lc_value = 'aleman' or $lc_value = 'german' or $lc_value = 'de' or $lc_value = 'deu'">
                <xsl:text>deu</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'italiano' or $lc_value = 'italian' or $lc_value = 'it' or $lc_value = 'ita'">
                <xsl:text>ita</xsl:text>
            </xsl:when>
            <!-- Lenguas indígenas de la lista common_iso_languages.
                 Chinanteco, Mazateco, Totonaco y Mixe no tienen código ISO 639-3 general y no se exportan. -->
            <xsl:when test="$lc_value = 'mazahua' or $lc_value = 'maz'">
                <xsl:text>maz</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'otomí' or $lc_value = 'otomi' or $lc_value = 'ots'">
                <xsl:text>ots</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'náhuatl' or $lc_value = 'nahuatl' or $lc_value = 'nah'">
                <xsl:text>nah</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'matlatzinca' or $lc_value = 'mat'">
                <xsl:text>mat</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'tlahuica' or $lc_value = 'ocu'">
                <xsl:text>ocu</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'maya' or $lc_value = 'yua'">
                <xsl:text>yua</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'zapoteco' or $lc_value = 'zap'">
                <xsl:text>zap</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'chocho (chocholteco)' or $lc_value = 'chocho' or $lc_value = 'chocholteco' or $lc_value = 'coz'">
                <xsl:text>coz</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!--
        dc.rights.accesslevel (lista openaire_rights) a la etiqueta COAR Access Rights.
        También acepta las etiquetas COAR en inglés. Devuelve vacío si no se reconoce.
     -->
    <xsl:template name="resolveCMAccessRight">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="normalize-space($field)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'acceso abierto' or $lc_value = 'open access'">
                <xsl:text>open access</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'acceso bajo embargo' or $lc_value = 'acceso embargado' or $lc_value = 'embargoed access'">
                <xsl:text>embargoed access</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'acceso restringido' or $lc_value = 'restricted access'">
                <xsl:text>restricted access</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'acceso cerrado' or $lc_value = 'metadata only access'">
                <xsl:text>metadata only access</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!--
        dc.type.publicationversion (lista openaire_version_types) a la etiqueta COAR Version Types.
        También acepta los valores DRIVER (info:eu-repo/semantics/...Version).
        https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_version.html
     -->
    <xsl:template name="resolveVersionLabel">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="normalize-space($field)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lc_value = 'borrador' or contains($lc_value, 'draft')">
                <xsl:text>AO</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'versión enviada' or $lc_value = 'version enviada' or contains($lc_value, 'submittedversion')">
                <xsl:text>SMUR</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'versión aceptada' or $lc_value = 'version aceptada' or contains($lc_value, 'acceptedversion')">
                <xsl:text>AM</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'versión publicada' or $lc_value = 'version publicada' or contains($lc_value, 'publishedversion')">
                <xsl:text>VoR</xsl:text>
            </xsl:when>
            <xsl:when test="$lc_value = 'versión actualizada' or $lc_value = 'version actualizada' or contains($lc_value, 'updatedversion')">
                <xsl:text>CVoR</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- URI COAR de cada etiqueta de versión -->
    <xsl:template name="resolveVersionURI">
        <xsl:param name="label"/>
        <xsl:choose>
            <xsl:when test="$label = 'AO'">
                <xsl:text>http://purl.org/coar/version/c_b1a7d7d4d402bcce</xsl:text>
            </xsl:when>
            <xsl:when test="$label = 'SMUR'">
                <xsl:text>http://purl.org/coar/version/c_71e4c1898caa6e32</xsl:text>
            </xsl:when>
            <xsl:when test="$label = 'AM'">
                <xsl:text>http://purl.org/coar/version/c_ab4af688f83e57aa</xsl:text>
            </xsl:when>
            <xsl:when test="$label = 'VoR'">
                <xsl:text>http://purl.org/coar/version/c_970fb48d4fbd8a85</xsl:text>
            </xsl:when>
            <xsl:when test="$label = 'CVoR'">
                <xsl:text>http://purl.org/coar/version/c_e19f295774971610</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--
        dc.audience (lista openaire_audience) al vocabulario de OpenAIRE (ERIC, en inglés).
        Devuelve vacío si no se reconoce.
     -->
    <xsl:template name="resolveAudience">
        <xsl:param name="field"/>
        <xsl:variable name="lc_value">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="normalize-space($field)"/>
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
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- quita el resolvedor (https://doi.org/, http://dx.doi.org/) y deja el DOI como 10.xxxx/... -->
    <xsl:template name="stripDOIResolver">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="contains($value, 'doi.org/')">
                <xsl:value-of select="substring-after($value, 'doi.org/')"/>
            </xsl:when>
            <xsl:when test="starts-with($value, 'doi:')">
                <xsl:value-of select="substring-after($value, 'doi:')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   <!-- xml:language -->
   <!-- this template will add a xml:lang parameter with the defined language of an element -->
    <xsl:template name="xmlLanguage">
        <xsl:param name="name"/>
        <xsl:variable name="lc_name">
            <xsl:call-template name="lowercase">
                <xsl:with-param name="value" select="$name"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$lc_name!='none' and $name!=''">
            <xsl:attribute name="xml:lang">
            <xsl:value-of select="$name"/>
         </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Prepare data for CC License -->
    <xsl:variable name="ccstart">
        <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"/>
    </xsl:variable>
    
    <!-- oaire:licenseCondition -->
    <!-- https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/4.0.1/field_licensecondition.html -->
    <!-- la licencia se cataloga en dcterms.license (nombre) y dcterms.license.uri
         (paso CustomCCLicenseStep). Si ambos están vacíos se usa la licencia CC de DSpace. -->
    <xsl:template name="licenseCondition">
        <xsl:variable name="licenseName"
            select="normalize-space(doc:metadata/doc:element[@name='dcterms']/doc:element[@name='license']/doc:element/doc:field[@name='value'][1])"/>
        <xsl:variable name="licenseURI"
            select="normalize-space(doc:metadata/doc:element[@name='dcterms']/doc:element[@name='license']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][1])"/>
        <xsl:choose>
            <xsl:when test="$licenseName != '' or $licenseURI != ''">
                <oaire:licenseCondition>
                    <xsl:if test="normalize-space($ccstart) != ''">
                        <xsl:attribute name="startDate">
                            <xsl:value-of select="$ccstart"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$licenseURI != ''">
                        <xsl:attribute name="uri">
                            <xsl:value-of select="$licenseURI"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$licenseName != ''">
                            <xsl:value-of select="$licenseName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$licenseURI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </oaire:licenseCondition>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates
                    select="doc:metadata/doc:element[@name='others']/doc:element[@name='cc']" mode="oaire" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
        match="doc:element[@name='others']/doc:element[@name='cc']"
        mode="oaire">
        <oaire:licenseCondition>
            <xsl:attribute name="startDate">
                <xsl:value-of
                    select="$ccstart"/>
            </xsl:attribute>
            <xsl:attribute name="uri">
                <xsl:value-of select="./doc:field[@name='uri']/text()" />
            </xsl:attribute>
            <xsl:value-of select="./doc:field[@name='name']/text()" />
        </oaire:licenseCondition>
    </xsl:template>

    <!-- ignore all non specified text values or attributes -->
    <xsl:template match="text()|@*"/>
    <xsl:template match="text()|@*" mode="oaire"/>
    <xsl:template match="text()|@*" mode="datacite"/>
    <xsl:template match="text()|@*" mode="entity_author"/>
    <xsl:template match="text()|@*" mode="entity_funding"/>
    <xsl:template match="text()|@*" mode="dc"/>

</xsl:stylesheet>
