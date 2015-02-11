<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xlink bk cals ce ja mml sa sb tb xocs dc prism sv" xmlns:bk="http://www.elsevier.com/xml/bk/dtd" xmlns:cals="http://www.elsevier.com/xml/common/cals/dtd" xmlns:ce="http://www.elsevier.com/xml/common/dtd" xmlns:ja="http://www.elsevier.com/xml/ja/dtd" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:sa="http://www.elsevier.com/xml/common/struct-aff/dtd" xmlns:sb="http://www.elsevier.com/xml/common/struct-bib/dtd" xmlns:tb="http://www.elsevier.com/xml/common/table/dtd" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xocs="http://www.elsevier.com/xml/xocs/dtd" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:prism="http://prismstandard.org/namespaces/basic/2.0/" xmlns:sv="http://www.elsevier.com/xml/svapi/article/dtd">

<xsl:output method="xml" indent="yes" encoding="ascii"/>

<xsl:template match="/">
        <xsl:variable name="curr" select="//ce:cross-ref"></xsl:variable>
                <xsl:variable name="test" select="$curr/../preceding-sibling::ce:section-title"></xsl:variable>

        <xsl:for-each select="$test">
        <sec>
                    <xsl:value-of select="."></xsl:value-of>
        </sec>
	</xsl:for-each>
</xsl:template>
</xsl:stylesheet>

