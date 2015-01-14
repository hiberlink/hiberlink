<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xlink bk cals ce ja mml sa sb tb xocs dc prism sv" xmlns:bk="http://www.elsevier.com/xml/bk/dtd" xmlns:cals="http://www.elsevier.com/xml/common/cals/dtd" xmlns:ce="http://www.elsevier.com/xml/common/dtd" xmlns:ja="http://www.elsevier.com/xml/ja/dtd" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:sa="http://www.elsevier.com/xml/common/struct-aff/dtd" xmlns:sb="http://www.elsevier.com/xml/common/struct-bib/dtd" xmlns:tb="http://www.elsevier.com/xml/common/table/dtd" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xocs="http://www.elsevier.com/xml/xocs/dtd" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:prism="http://prismstandard.org/namespaces/basic/2.0/" xmlns:sv="http://www.elsevier.com/xml/svapi/article/dtd">

<xsl:output method="xml" indent="yes" encoding="ascii"/>

<!-- XXX ja:head -->

<xsl:template match="/">
  <document>
    <title>
      <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/dc:title"/>
    </title>
    <authors>
      <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/sv:authors"/>
    </authors>
    <dates>
      <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/prism:coverDate"/>
      <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:originalText/xocs:doc/xocs:meta/xocs:orig-load-date"/>
      <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:originalText/xocs:doc/xocs:meta/xocs:ew-transaction-id"/>
      <xsl:apply-templates select="//ce:date-received"/>
      <xsl:apply-templates select="//ce:date-accepted"/>
    </dates>
    <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/prism:issn"/>
    <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/prism:doi"/>
    <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/sv:openaccessFlag"/>
    <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/prism:publicationName"/>
    <xsl:apply-templates select="/sv:full-text-retrieval-response/sv:coredata/prism:aggregationType"/>
    <links>
      <xsl:apply-templates select="//*[@xlink:href|@href]"/>
    </links>
  </document>
</xsl:template>

<xsl:template match="prism:doi">
  <doi>
    <xsl:value-of select="."/>
  </doi>
</xsl:template>

<xsl:template match="prism:issn">
  <issn>
    <xsl:value-of select="."/>
  </issn>
</xsl:template>

<xsl:template match="prism:publicationName">
  <subject>
    <xsl:value-of select="."/>
  </subject>
</xsl:template>

<xsl:template match="prism:aggregationType">
  <pubtype>
      <xsl:value-of select="."/>
  </pubtype>
</xsl:template>


<xsl:template match="sv:openaccessFlag">
  <open-access><xsl:value-of select="."/></open-access>
</xsl:template>

<xsl:template match="prism:coverDate">
  <date type="ppub">
    <day><xsl:value-of select="substring(., 9, 2)"/></day>
    <month><xsl:value-of select="substring(., 6, 2)"/></month>
    <year><xsl:value-of select="substring(., 1, 4)"/></year>
  </date>
</xsl:template>

<xsl:template match="xocs:orig-load-date|xocs:ew-transaction-id">
  <date type="{local-name()}">
    <day><xsl:value-of select="substring(., 9, 2)"/></day>
    <month><xsl:value-of select="substring(., 6, 2)"/></month>
    <year><xsl:value-of select="substring(., 1, 4)"/></year>
  </date>
</xsl:template>

<xsl:template match="ce:date-received">
  <date type="received">
    <day><xsl:value-of select="@day"/></day>
    <month><xsl:value-of select="@month"/></month>
    <year><xsl:value-of select="@year"/></year>
  </date>
</xsl:template>

<xsl:template match="ce:date-accepted">
  <date type="accepted">
    <day><xsl:value-of select="@day"/></day>
    <month><xsl:value-of select="@month"/></month>
    <year><xsl:value-of select="@year"/></year>
  </date>
</xsl:template>

<xsl:template match="*[@xlink:href]">
  <link>
    <xsl:call-template name="section"/>
    <xsl:value-of select="@xlink:href"/>
  </link>
</xsl:template>

<xsl:template match="*[@href]">
  <link>
    <xsl:apply-templates select="@rel"/>
    <xsl:call-template name="section"/>
    <xsl:value-of select="@href"/>
  </link>
</xsl:template>

<xsl:template match="*[@href]/@rel">
  <xsl:attribute name="to"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template name="section">
<!-- XXX -->
</xsl:template>


</xsl:stylesheet>
