<!--
  Generates single FO document from DocBook XML source using DocBook XSL
  stylesheets.

  See xsl-stylesheets/fo/param.xsl for all parameters.

  NOTE: The URL reference to the current DocBook XSL stylesheets is
  rewritten to point to the copy on the local disk drive by the XML catalog
  rewrite directives so it doesn't need to go out to the Internet for the
  stylesheets. This means you don't need to edit the <xsl:import> elements on
  a machine by machine basis.
-->

<!--
    TODO 2012-03-12 HUGR: Get better ruler and check paragraph indent.
    TODO 2012-03-12 HUGR: Make Charm headers (and other bits) non-justified.
    TODO 2012-03-12 HUGR: Change fonts.
    TODO 2012-03-12 HUGR: Put page numbers in margin in footer.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>
<xsl:import href="common.xsl"/>

<xsl:param name="fop1.extensions" select="1" />
<xsl:param name="variablelist.as.blocks" select="1" />

<!--
<xsl:param name="paper.type" select="'A4'"/>
-->
<xsl:param name="paper.type" select="'USletter'"/>
<xsl:param name="hyphenate">true</xsl:param>
<!-- justify, left or right -->
<xsl:param name="alignment">justify</xsl:param>
<xsl:param name="double.sided" select="1"/>

<xsl:param name="body.font.family" select="'serif'"/>
<xsl:param name="body.font.master">12</xsl:param>
<xsl:param name="body.font.size">
 <xsl:value-of select="$body.font.master"/><xsl:text>pt</xsl:text>
</xsl:param>

<xsl:param name="body.margin.bottom" select="'0.5in'"/>
<xsl:param name="body.margin.top" select="'0.5in'"/>
<xsl:param name="bridgehead.in.toc" select="0"/>

<!-- overide setting in common.xsl -->
<xsl:param name="table.frame.border.thickness" select="'2px'"/>

<!-- Default fetches image from Internet (long timeouts) -->
<xsl:param name="draft.watermark.image" select="''"/>

<!-- Line break -->
<xsl:template match="processing-instruction('asciidoc-br')">
  <fo:block/>
</xsl:template>

<!-- Horizontal ruler -->
<xsl:template match="processing-instruction('asciidoc-hr')">
  <fo:block space-after="1em">
    <fo:leader leader-pattern="rule" rule-thickness="0.5pt"  rule-style="solid" leader-length.minimum="100%"/>
  </fo:block>
</xsl:template>

<!-- Hard page break -->
<xsl:template match="processing-instruction('asciidoc-pagebreak')">
   <fo:block break-after='page'/>
</xsl:template>

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
<xsl:param name="page.margin.bottom" select="'0.25in'"/>
<xsl:param name="page.margin.inner">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">0.75in</xsl:when>
    <!-- <xsl:otherwise>0.75in</xsl:otherwise> -->
    <xsl:otherwise>0.5in</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.margin.outer">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">0.5in</xsl:when>
    <!-- <xsl:otherwise>0.5in</xsl:otherwise> -->
    <xsl:otherwise>1.2in</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="page.margin.top" select="'0.5in'"/>
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

<xsl:attribute-set name="monospace.properties">
  <xsl:attribute name="font-size">10pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="admonition.title.properties">
  <xsl:attribute name="font-size">14pt</xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="sidebar.properties" use-attribute-sets="formal.object.properties">
  <xsl:attribute name="border-style">solid</xsl:attribute>
  <xsl:attribute name="border-width">1pt</xsl:attribute>
  <xsl:attribute name="border-color">silver</xsl:attribute>
  <xsl:attribute name="background-color">#ffffee</xsl:attribute>
  <xsl:attribute name="padding-left">12pt</xsl:attribute>
  <xsl:attribute name="padding-right">12pt</xsl:attribute>
  <xsl:attribute name="padding-top">6pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">6pt</xsl:attribute>
  <xsl:attribute name="margin-left">0pt</xsl:attribute>
  <xsl:attribute name="margin-right">12pt</xsl:attribute>
  <xsl:attribute name="margin-top">6pt</xsl:attribute>
  <xsl:attribute name="margin-bottom">6pt</xsl:attribute>
</xsl:attribute-set>

<xsl:param name="callout.graphics" select="'1'"/>

<!-- Only shade programlisting and screen verbatim elements -->
<xsl:param name="shade.verbatim" select="1"/>
<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="background-color">
    <xsl:choose>
      <xsl:when test="self::programlisting|self::screen">#E0E0E0</xsl:when>
      <xsl:otherwise>inherit</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<!--
  Force XSL Stylesheets 1.72 default table breaks to be the same as the current
  version (1.74) default which (for tables) is keep-together="auto".
-->
<xsl:attribute-set name="table.properties">
  <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
</xsl:attribute-set>


<!--
<xsl:param name="section.autolabel" select="0"></xsl:param>
<xsl:param name="chapter.autolabel" select="0"></xsl:param>
-->
<!--
  Two-column by default.
-->
<xsl:param name="column.count.body" select="2"/>
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
  Chapter heading customisation.
-->
<xsl:attribute-set name="chapter.titlepage.recto.style">
  <xsl:attribute name="background-image">url('../book/Discordians_Title_Backdrop.png')</xsl:attribute>
  <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
  <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
  <xsl:attribute name="padding-top">36pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">42pt</xsl:attribute>
  <xsl:attribute name="border">solid blue</xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="component.titlepage.properties">
  <xsl:attribute name="span">all</xsl:attribute>
  <xsl:attribute name="padding-top">24pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">36pt</xsl:attribute>
  <xsl:attribute name="border">solid green</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="footer.table.properties">
  <xsl:attribute name="border">solid green</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="footer.content.properties">
  <xsl:attribute name="border">dashed red</xsl:attribute>
  <xsl:attribute name="margin-{$direction.align.start}">0pt</xsl:attribute>
</xsl:attribute-set>

<!--
<xsl:template match="chapter|appendix" mode="intralabel.punctuation">
  <xsl:text>:</xsl:text>
</xsl:template>
-->
<xsl:template match="chapter" mode="label.markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="string($chapter.autolabel) != 0">
      <xsl:if test="$component.label.includes.part.label != 0 and
                      ancestor::part">
        <xsl:variable name="part.label">
          <xsl:apply-templates select="ancestor::part" 
                               mode="label.markup"/>
        </xsl:variable>
        <xsl:if test="$part.label != ''">
          <xsl:value-of select="$part.label"/>
          <xsl:apply-templates select="ancestor::part" 
                               mode="intralabel.punctuation"/>
        </xsl:if>
      </xsl:if>
<!--
      <xsl:variable name="format">
        <xsl:call-template name="autolabel.format">
          <xsl:with-param name="format" select="$chapter.autolabel"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$label.from.part != 0 and ancestor::part">
          <xsl:number from="part" count="chapter" format="{$format}" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number from="book" count="chapter" format="{$format}" level="any"/>
        </xsl:otherwise>
      </xsl:choose>
-->
      <xsl:variable name="my.number">
        <xsl:choose>
          <xsl:when test="$label.from.part != 0 and ancestor::part">
            <xsl:number from="part" count="chapter" format="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number from="book" count="chapter" format="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$my.number = '1'">
          <xsl:text>One</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          Oops!
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>: </xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>


<!-- Section heading properties -->
<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="space-before.minimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-size"><xsl:text>24pt</xsl:text></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="font-size"><xsl:text>14pt</xsl:text></xsl:attribute>
</xsl:attribute-set>

<!-- Indent paragraphs -->
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
  <xsl:attribute name="text-indent">18pt</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
