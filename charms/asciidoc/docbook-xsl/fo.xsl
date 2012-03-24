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
    TODO 2012-03-12 HUGR: Make Charm headers (and other bits) non-justified.
    TODO 2012-03-24 HUGR: Credits page.
    TODO 2012-03-24 HUGR: Proper background image for header.
    TODO 2012-03-24 HUGR: Proper background image for outer margin.
    TODO 2012-03-24 HUGR: ... or combine the above two into page background?
    TODO 2012-03-24 HUGR: Background image for page numbers.
    TODO 2012-03-24 HUGR: Leading zeros in page numbers.
    TODO 2012-03-24 HUGR: Footer rule.
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

<xsl:param name="title.font.family" select="'Artisan12'"/>
<xsl:param name="body.font.family" select="'GoudyStMTT'"/>
<xsl:param name="body.font.master">10</xsl:param>
<xsl:param name="body.font.size">
 <xsl:value-of select="$body.font.master"/><xsl:text>pt</xsl:text>
</xsl:param>
<xsl:param name="line-height">110%</xsl:param>

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
<xsl:attribute-set name="preface.titlepage.recto.style">
  <xsl:attribute name="background-image">url('../book/Discordians_Title_Backdrop.png')</xsl:attribute>
  <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
  <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
  <xsl:attribute name="padding-top">36pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">42pt</xsl:attribute>
  <xsl:attribute name="border">solid blue</xsl:attribute>
  <xsl:attribute name="min-height">300pt</xsl:attribute>
  <xsl:attribute name="height">300pt</xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="chapter.titlepage.recto.style">
  <xsl:attribute name="background-image">url('../book/Discordians_Title_Backdrop.png')</xsl:attribute>
  <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
  <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
  <xsl:attribute name="padding-top">36pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">42pt</xsl:attribute>
  <xsl:attribute name="border">solid blue</xsl:attribute>
  <xsl:attribute name="min-height">300pt</xsl:attribute>
  <xsl:attribute name="height">300pt</xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="component.titlepage.properties">
  <xsl:attribute name="span">all</xsl:attribute>
  <xsl:attribute name="padding-top">24pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">36pt</xsl:attribute>
  <xsl:attribute name="border">solid green</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="component.title.properties">
  <xsl:attribute name="margin-left">84pt</xsl:attribute>
  <xsl:attribute name="margin-right">84pt</xsl:attribute>
  <xsl:attribute name="min-height">84pt</xsl:attribute>
  <xsl:attribute name="border">solid red</xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
  <xsl:attribute name="line-height">120%</xsl:attribute>
</xsl:attribute-set>

<xsl:param name="header.rule" select="0"></xsl:param>
<xsl:param name="header.column.widths">0 1 0</xsl:param>
<xsl:param name="header.image.filename">../book/Discordians_Title_Backdrop.png</xsl:param>
<xsl:template name="header.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

<!--
  <fo:block>
    <xsl:value-of select="$pageclass"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$sequence"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$position"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$gentext-key"/>
  </fo:block>
-->

  <fo:block>

    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$sequence = 'blank'">
        <!-- nothing -->
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and $sequence = 'even'
                      and $position='left'">
	<xsl:attribute name="margin-{$direction.align.start}">-0.6in</xsl:attribute>
	<fo:external-graphic content-height="0.6in">
	  <xsl:attribute name="src">
	    <xsl:call-template name="fo-external-image">
	      <xsl:with-param name="filename" select="$header.image.filename"/>
	    </xsl:call-template>
	  </xsl:attribute>
	</fo:external-graphic>
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and ($sequence = 'odd' or $sequence = 'first')
                      and $position='right'">
	<xsl:attribute name="margin-{$direction.align.end}">-0.6in</xsl:attribute>
	<fo:external-graphic content-height="0.6in">
	  <xsl:attribute name="src">
	    <xsl:call-template name="fo-external-image">
	      <xsl:with-param name="filename" select="$header.image.filename"/>
	    </xsl:call-template>
	  </xsl:attribute>
	</fo:external-graphic>
      </xsl:when>


      <xsl:when test="$position='center'">
        <!-- nothing for empty and blank sequences -->
      </xsl:when>

      <xsl:when test="$position='right'">
        <!-- Same for odd, even, empty, and blank sequences -->
        <xsl:call-template name="draft.text"/>
      </xsl:when>

      <xsl:when test="$sequence = 'first'">
        <!-- nothing for first pages -->
      </xsl:when>

      <xsl:when test="$sequence = 'blank'">
        <!-- nothing for blank pages -->
      </xsl:when>
    </xsl:choose>
  </fo:block>
</xsl:template>

<!--
<xsl:attribute-set name="footer.table.properties">
  <xsl:attribute name="border">solid green</xsl:attribute>
</xsl:attribute-set>
-->
<xsl:attribute-set name="footer.content.properties">
  <xsl:attribute name="font-family">Artisan12</xsl:attribute>
</xsl:attribute-set>
<xsl:param name="footer.column.widths">1 8 1</xsl:param>
<xsl:template name="footer.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

<!--
  <fo:block>
    <xsl:value-of select="$pageclass"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$sequence"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$position"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$gentext-key"/>
  </fo:block>
-->

  <fo:block>
    <!-- pageclass can be front, body, back -->
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$pageclass = 'titlepage'">
        <!-- nop; no footer on title pages -->
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and $sequence = 'even'
                      and $position='left'">
	<xsl:attribute name="margin-{$direction.align.start}">-0.6in</xsl:attribute>
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and ($sequence = 'odd' or $sequence = 'first')
                      and $position='right'">
	<xsl:attribute name="margin-{$direction.align.end}">-0.6in</xsl:attribute>
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and ($sequence = 'odd' or $sequence = 'first')
		      and $position='center'">
	<xsl:if test="$gentext-key='Chapter' or $gentext-key='chapter'">
	  <xsl:call-template name="gentext">
	    <xsl:with-param name="key" select="$gentext-key"/>
	  </xsl:call-template> 
	  <xsl:text> </xsl:text>
	  <xsl:apply-templates select="." mode="label.markup"/>
	  <xsl:text> &#x00b7; </xsl:text>
	</xsl:if>
	<xsl:apply-templates select="." mode="title.markup"/>
      </xsl:when>

      <xsl:when test="$double.sided = 0 and $position='center'">
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$sequence='blank'">
        <xsl:choose>
          <xsl:when test="$double.sided != 0 and $position = 'left'">
            <fo:page-number/>
          </xsl:when>
          <xsl:when test="$double.sided = 0 and $position = 'center'">
            <fo:page-number/>
          </xsl:when>
          <xsl:otherwise>
            <!-- nop -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>


      <xsl:otherwise>
        <!-- nop -->
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

<!-- Chapter label formatting -->
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
        <xsl:when test="$my.number = '1'"><xsl:text>One</xsl:text></xsl:when>
        <xsl:when test="$my.number = '2'"><xsl:text>Two</xsl:text></xsl:when>
        <xsl:when test="$my.number = '3'"><xsl:text>Three</xsl:text></xsl:when>
        <xsl:when test="$my.number = '4'"><xsl:text>Four</xsl:text></xsl:when>
        <xsl:when test="$my.number = '5'"><xsl:text>Five</xsl:text></xsl:when>
        <xsl:when test="$my.number = '6'"><xsl:text>Six</xsl:text></xsl:when>
        <xsl:when test="$my.number = '7'"><xsl:text>Seven</xsl:text></xsl:when>
        <xsl:when test="$my.number = '8'"><xsl:text>Eight</xsl:text></xsl:when>
        <xsl:when test="$my.number = '9'"><xsl:text>Nine</xsl:text></xsl:when>
        <xsl:otherwise>
          <xsl:text>OOPS!</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!--
<xsl:template match="chapter|appendix|section" mode="intralabel.punctuation">
<xsl:template match="*" mode="intralabel.punctuation">
  <xsl:text>:</xsl:text>
</xsl:template>
-->
<xsl:param name="local.l10n.xml" select="document('')"/>
<l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
  <l:l10n language="en">
<!--
    <l:context name="title">
      <l:template name="chapter" text="Chapter %n: %t"/>
    </l:context>
-->
    <l:context name="title-numbered">
      <l:template name="chapter" text="Chapter %n: %t"/>
    </l:context>
<!--
    <l:context name="title-unnumbered">
      <l:template name="chapter" text="Chapter %n: %t"/>
    </l:context>
-->
    <l:context name="xref">
      <l:template name="chapter" text="Chapter %n: %t"/>
    </l:context>
    <l:context name="xref-number-and-title">
      <l:template name="chapter" text="Chapter %n: %t"/>
    </l:context>
  </l:l10n>
</l:i18n>

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


<!--
    Table of Contents
-->

<xsl:param name="toc.section.depth" select="'0'"/>
<xsl:param name="autotoc.label.separator">: </xsl:param>
<xsl:attribute-set name="toc.line.properties">
  <xsl:attribute name="font-family">Artisan12</xsl:attribute>
  <xsl:attribute name="font-size">14pt</xsl:attribute>
  <xsl:attribute name="margin-left">0.4in</xsl:attribute>
  <xsl:attribute name="margin-right">0.6in</xsl:attribute>
  <xsl:attribute name="line-height">160%</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="toc.margin.properties">
  <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">1em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">2em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">1em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">2em</xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
<!--
  <xsl:attribute name="border">dashed red</xsl:attribute>
-->
</xsl:attribute-set>

<!-- http://www.sagehill.net/docbookxsl/PrintToc.html -->
<xsl:template name="table.of.contents.titlepage.before.recto">
  <fo:block
      padding-top="1.5in" padding-bottom="2.5in"
      text-align="center"
      >
<!--
      border="dashed purple">
-->
    <fo:external-graphic
	block-progression-dimension="1.5in"
      >
<!--
	border="solid thick purple">
-->
      <xsl:attribute name="src">
	<xsl:call-template name="fo-external-image">
	  <xsl:with-param name="filename" select="$header.image.filename"/>
	</xsl:call-template>
      </xsl:attribute>
    </fo:external-graphic>
  </fo:block>
</xsl:template>
<xsl:attribute-set name="table.of.contents.titlepage.recto.style">
  <xsl:attribute name="border">solid orange</xsl:attribute>
</xsl:attribute-set>
<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="NOTANODE"/>  
  <xsl:variable name="id">  
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">  
    <xsl:apply-templates select="." mode="label.markup"/>  
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="toc.line.properties">  
    <fo:inline keep-with-next.within-line="always">
      
      <fo:basic-link internal-destination="{$id}">  

        <xsl:if test="self::appendix or self::chapter">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name()"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>

        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="title.markup"/>  
      </fo:basic-link>
    </fo:inline>
    <fo:inline keep-together.within-line="always"> 
      <xsl:text> </xsl:text>
      <fo:leader leader-pattern="space"
                 keep-with-next.within-line="always"/>
      <xsl:text> </xsl:text>
      <fo:basic-link internal-destination="{$id}">
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>



<!-- Section heading properties -->
<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="space-before.minimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6pt</xsl:attribute>
  <xsl:attribute name="line-height">170%</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-size">24pt</xsl:attribute>
  <xsl:attribute name="line-height">120%</xsl:attribute>
  <xsl:attribute name="margin-bottom">10pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="font-size">18pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level3.properties">
  <xsl:attribute name="font-size">14pt</xsl:attribute>
</xsl:attribute-set>

<!-- Indent paragraphs -->
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
  <xsl:attribute name="text-indent">18pt</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
