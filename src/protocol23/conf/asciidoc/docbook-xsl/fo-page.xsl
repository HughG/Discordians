<!--
    Page-level bits of styling.
-->

<!--
    TODO 2012-03-24 hughg: Credits page.

    TODO 2012-03-24 hughg: Proper background image for header.

    TODO 2012-03-24 hughg: Proper background image for outer margin.

    TODO 2012-03-24 hughg: ... or combine the above two into page background?

    TODO 2012-03-24 hughg: Background image for page numbers.

    TODO 2012-03-26 hughg: First-of-chapter pages are always like right pages, even if they're left pages.

    TODO 2012-03-31 hughg: Try doing page numbers using a margin note?
-->

<!DOCTYPE xsl:stylesheet [
<!ENTITY % common.entities SYSTEM "/opt/local/share/xsl/docbook-xsl/common/entities.ent">
%common.entities;
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:param name="paper.type" select="'USletter'"/>
<xsl:param name="hyphenate">true</xsl:param>
<xsl:param name="alignment">justify</xsl:param>
<xsl:param name="double.sided" select="1"/>
<xsl:template name="force.page.count">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:param name="master-reference" select="''"/>

  no-force
<!--
  <xsl:choose>
    <! - - double-sided output - - >
    <xsl:when test="$double.sided != 0">end-on-even</xsl:when>
    <! - - single-sided output - - >
    <xsl:otherwise>no-force</xsl:otherwise>
  </xsl:choose>
-->
</xsl:template>

<xsl:param name="title.font.family" select="'LibertinageBasicSC'"/>
<xsl:param name="body.font.family" select="'GoudyStMTT'"/>
<xsl:param name="body.font.master">10</xsl:param>
<xsl:param name="body.font.size">
 <xsl:value-of select="$body.font.master"/><xsl:text>pt</xsl:text>
</xsl:param>
<xsl:param name="line-height">110%</xsl:param>

<xsl:param name="body.margin.bottom" select="'0.3in'"/>
<xsl:param name="body.margin.top" select="'0in'"/>

<!--
<xsl:param name="draft.mode" select="'yes'"/>
-->
<!-- Default fetches image from Internet (long timeouts) -->
<xsl:param name="draft.watermark.image">../book/background_marble.png</xsl:param>

<!-- Sets title to body text indent -->
<xsl:param name="body.start.indent">
  <xsl:choose>
    <xsl:when test="$fop.extensions != 0">0pt</xsl:when>
    <xsl:when test="$passivetex.extensions != 0">0pt</xsl:when>
    <!-- <xsl:otherwise>1pc</xsl:otherwise> -->
    <xsl:otherwise>0pt</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="title.margin.left">
  <xsl:choose>
    <xsl:when test="$fop.extensions != 0">-1pc</xsl:when>
    <xsl:when test="$passivetex.extensions != 0">0pt</xsl:when>
    <xsl:otherwise>0pt</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="page.margin.top" select="'0.95in'"/>
<xsl:param name="page.margin.bottom" select="'0.1in'"/>
<xsl:param name="page.margin.inner">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">0.75in</xsl:when>
    <!-- <xsl:otherwise>0.75in</xsl:otherwise> -->
    <xsl:otherwise>1.2in</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.margin.outer">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">1.0in</xsl:when>
    <!-- <xsl:otherwise>0.5in</xsl:otherwise> -->
    <xsl:otherwise>0.5in</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="page.orientation" select="'portrait'"/>
<xsl:param name="page.width">
  <xsl:choose>
    <xsl:when test="$page.orientation = 'portrait'">
      <xsl:value-of select="$page.width.portrait"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$page.height.portrait"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="appendix.autolabel" select="0"></xsl:param>
<!--
  Two-column by default.
-->
<xsl:param name="column.count.body" select="2"/>
<xsl:param name="column.count.front" select="2"/>
<!--
  Single-column for pgwide attribute.
-->
<xsl:attribute-set name="pgwide.properties">
  <xsl:attribute name="span">all</xsl:attribute>
  <xsl:attribute name="padding-top">12pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">12pt</xsl:attribute>
</xsl:attribute-set>
<!--
  This hack from http://www.sagehill.net/docbookxsl/MultiColumns.html
  allows column spanning blocks within a section, rather than just
  at the start of a section.
-->
<xsl:param name="section.container.element">wrapper</xsl:param>

<!--
    Page numbering
-->
<xsl:template name="page.number.format">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:param name="master-reference" select="''"/>

  1
<!--
  <xsl:choose>
    <xsl:when test="$element = 'toc' and self::book">i</xsl:when>
    <xsl:when test="$element = 'preface'">i</xsl:when>
    <xsl:when test="$element = 'dedication'">i</xsl:when>
    <xsl:when test="$element = 'acknowledgements'">i</xsl:when>
    <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
-->
</xsl:template>

<xsl:template name="initial.page.number">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:param name="master-reference" select="''"/>

  <!-- Select the first content that the stylesheet places
       after the TOC -->
  <xsl:variable name="first.book.content" 
                select="ancestor::book/*[
                          not(self::title or
                              self::subtitle or
                              self::titleabbrev or
                              self::bookinfo or
                              self::info or
                              self::dedication or
                              self::acknowledgements or
                              self::preface or
                              self::toc or
                              self::lot)][1]"/>
  <xsl:choose>
    <!-- double-sided output -->
    <xsl:when test="$double.sided != 0">
      <xsl:choose>
<!--
        <xsl:when test="$element = 'toc'">auto-odd</xsl:when>
-->
        <xsl:when test="$element = 'book'">1</xsl:when>
        <!-- preface typically continues TOC roman numerals -->
        <!-- Change page.number.format if not -->
<!--
        <xsl:when test="$element = 'preface'">auto-odd</xsl:when>
        <xsl:when test="($element = 'dedication' or $element = 'article') 
                    and not(preceding::chapter
                            or preceding::preface
                            or preceding::appendix
                            or preceding::article
                            or preceding::dedication
                            or parent::part
                            or parent::reference)">1</xsl:when>
        <xsl:when test="generate-id($first.book.content) =
                        generate-id(.)">1</xsl:when>
        <xsl:otherwise>auto-odd</xsl:otherwise>
-->
        <xsl:otherwise>auto</xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <!-- single-sided output -->
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$element = 'toc'">auto</xsl:when>
        <xsl:when test="$element = 'book'">1</xsl:when>
        <xsl:when test="$element = 'preface'">auto</xsl:when>
<!--
        <xsl:when test="($element = 'dedication' or $element = 'article') and
                        not(preceding::chapter
                            or preceding::preface
                            or preceding::appendix
                            or preceding::article
                            or preceding::dedication
                            or parent::part
                            or parent::reference)">1</xsl:when>
        <xsl:when test="generate-id($first.book.content) =
                        generate-id(.)">1</xsl:when>
-->
        <xsl:otherwise>auto</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Section heading properties -->
<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="space-before.minimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6pt</xsl:attribute>
  <xsl:attribute name="space-after.minimum">3pt</xsl:attribute>
  <xsl:attribute name="space-after.optimum">3pt</xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-size">
    <xsl:value-of select="20 * $title.font.size.factor"/>
    <xsl:text>pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="line-height">105%</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="font-size">
    <xsl:value-of select="18 * $title.font.size.factor"/>
    <xsl:text>pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="line-height">105%</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level3.properties">
  <xsl:attribute name="font-size">
    <xsl:value-of select="14 * $title.font.size.factor"/>
    <xsl:text>pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="line-height">105%</xsl:attribute>
</xsl:attribute-set>

<!--
    Section levels 4 and 5 aren't supported by AsciiDoc by default.
-->


<!-- Indent paragraphs -->
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
  <xsl:attribute name="text-indent">18pt</xsl:attribute>
</xsl:attribute-set>

<!-- Don't indent specially-marked paragraphs -->
<xsl:attribute-set name="noindent.para.spacing">
  <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
  <xsl:attribute name="text-indent">0pt</xsl:attribute>
</xsl:attribute-set>
<xsl:template match="simpara[@role='noindent']">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="noindent.para.spacing">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
