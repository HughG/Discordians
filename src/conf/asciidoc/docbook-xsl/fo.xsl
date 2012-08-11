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
    TODO 2012-03-12 HUGR: Background image(s) for sidebars.

    TODO 2012-03-24 HUGR: Credits page.

    TODO 2012-03-25 HUGR: Make INDEX & character sheeet heading smaller.  Need to fiddle with page templates.

    TODO 2012-03-26 HUGR: First-of-chapter pages are always like right pages, even if they're left pages.

    TODO 2012-03-30 HUGR: Sort out smart quotes.

    TODO 2012-03-30 HUGR: Use bibliography stuff.
-->

<!DOCTYPE xsl:stylesheet [
<!ENTITY % common.entities SYSTEM "/opt/local/share/xsl/docbook-xsl/common/entities.ent">
%common.entities;
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>
<xsl:import href="common.xsl"/>

<xsl:param name="fop1.extensions" select="1" />

<xsl:include href="fo-page.xsl"/>
<xsl:include href="fo-bibliography.xsl"/>

<xsl:param name="variablelist.as.blocks" select="1" />

<!--
    Workaround for FOP bug involving hyphenation and empty inline or
    anchor elements.  Unicode FEFF is zero-width no-break space.

    Bug:
    https://issues.apache.org/bugzilla/show_bug.cgi?id=48765

    Workaround:
    https://issues.apache.org/bugzilla/show_bug.cgi?id=48765#c6
-->
<xsl:template match="anchor">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <fo:inline id="{$id}">&#xFEFF;</fo:inline>
</xsl:template>

<!-- overide setting in common.xsl -->
<xsl:param name="table.frame.border.thickness" select="'2px'"/>

<xsl:include href="fo-asciidoc.xsl"/>

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
  <xsl:attribute name="border-color">black</xsl:attribute>
  <xsl:attribute name="background-color">#f0c0c0</xsl:attribute>
  <xsl:attribute name="padding-left">12pt</xsl:attribute>
  <xsl:attribute name="padding-right">12pt</xsl:attribute>
  <xsl:attribute name="padding-top">12pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">12pt</xsl:attribute>
  <xsl:attribute name="margin-left">0pt</xsl:attribute>
  <xsl:attribute name="margin-right">0pt</xsl:attribute>
  <xsl:attribute name="margin-top">6pt</xsl:attribute>
  <xsl:attribute name="margin-bottom">6pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="sidebar.title.properties">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="font-size">14pt</xsl:attribute>
  <xsl:attribute name="line-height">120%</xsl:attribute>
<!--
  <xsl:attribute name="space-after">6pt</xsl:attribute>
-->
</xsl:attribute-set>

<xsl:template match="sidebar" name="sidebar">
  <!-- Also does margin notes -->
  <xsl:variable name="pi-type">
    <xsl:call-template name="pi.dbfo_float-type"/>
  </xsl:variable>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <!-- Some don't have a pgwide attribute, so may use a PI -->
  <xsl:variable name="pgwide.pi">
    <xsl:call-template name="pi.dbfo_pgwide"/>
  </xsl:variable>

  <xsl:variable name="pgwide">
    <xsl:choose>
      <xsl:when test="@pgwide">
        <xsl:value-of select="@pgwide"/>
      </xsl:when>
      <xsl:when test="$pgwide.pi">
        <xsl:value-of select="$pgwide.pi"/>
      </xsl:when>
      <!-- child element may set pgwide -->
      <xsl:when test="*[@pgwide]">
        <xsl:value-of select="*[@pgwide][1]/@pgwide"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$pi-type = 'margin.note'">
      <xsl:call-template name="margin.note"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="content">
	<xsl:choose>
	  <!--
	      HUGR 2012-03-30: Allow sidebars to use pgwide.properties.
	  -->
	  <xsl:when test="$pgwide = '1'">
	    <fo:block xsl:use-attribute-sets="pgwide.properties
					      sidebar.properties"
		      id="{$id}">
	      <xsl:call-template name="sidebar.titlepage"/>
	      <xsl:apply-templates select="node()[not(self::title) and
					   not(self::info) and
					   not(self::sidebarinfo)]"/>
	    </fo:block>
	  </xsl:when>
	  <xsl:otherwise>
	    <fo:block xsl:use-attribute-sets="sidebar.properties"
		      id="{$id}">
	      <xsl:call-template name="sidebar.titlepage"/>
	      <xsl:apply-templates select="node()[not(self::title) and
					   not(self::info) and
					   not(self::sidebarinfo)]"/>
	    </fo:block>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="pi-width">
        <xsl:call-template name="pi.dbfo_sidebar-width"/>
      </xsl:variable>

      <xsl:variable name="position">
        <xsl:choose>
          <xsl:when test="$pi-type != ''">
            <xsl:value-of select="$pi-type"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$sidebar.float.type"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    
      <xsl:call-template name="floater">
        <xsl:with-param name="content" select="$content"/>
        <xsl:with-param name="position" select="$position"/>
        <xsl:with-param name="width">
          <xsl:choose>
            <xsl:when test="$pi-width != ''">
              <xsl:value-of select="$pi-width"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sidebar.float.width"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="start.indent">
          <xsl:choose>
            <xsl:when test="$position = 'start' or 
                            $position = 'left'">0pt</xsl:when>
            <xsl:when test="$position = 'end' or 
                            $position = 'right'">0.5em</xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="end.indent">
          <xsl:choose>
            <xsl:when test="$position = 'start' or 
                            $position = 'left'">0.5em</xsl:when>
            <xsl:when test="$position = 'end' or 
                            $position = 'right'">0pt</xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

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
  Give links a blue border, as in White Wolf's own PDFs.

  TODO 2012-08-11 HUGR: Don't display the border in print.
-->
<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="border">0.5pt solid blue</xsl:attribute>
</xsl:attribute-set>

<!-- Put in page numbers for xrefs -->
<!--
  TODO 2012-08-11 HUGR: This crashes FOP 1.0 because of

    https://issues.apache.org/bugzilla/show_bug.cgi?id=52411

  which is a duplicate of

    https://issues.apache.org/bugzilla/show_bug.cgi?id=50276

  which is fixed in "1.1dev".  I'll have to wait until 1.1 is released and
  MacPorts picks it up.

<xsl:param name="insert.xref.page.number" select="yes"></xsl:param>
-->

<!-- xref label customisation. -->
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
      <l:template name="section" text="%t"/>
    </l:context>
    <l:context name="xref-number-and-title">
      <l:template name="chapter" text="Chapter %n: %t"/>
    </l:context>
  </l:l10n>
</l:i18n>


<xsl:param name="appendix.autolabel" select="0"></xsl:param>

<!--
  Chapter heading customisation.
-->
<xsl:attribute-set name="preface.titlepage.recto.style">
  <xsl:attribute name="background-image">url('src/text/book/Discordians_Title_Backdrop.png')</xsl:attribute>
  <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
  <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
  <xsl:attribute name="padding-top">36pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">42pt</xsl:attribute>
<!--
  <xsl:attribute name="border">solid blue</xsl:attribute>
-->
  <xsl:attribute name="min-height">300pt</xsl:attribute>
  <xsl:attribute name="height">300pt</xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="chapter.titlepage.recto.style">
  <xsl:attribute name="background-image">url('src/text/book/Discordians_Title_Backdrop.png')</xsl:attribute>
  <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
  <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
  <xsl:attribute name="padding-top">36pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">42pt</xsl:attribute>
<!--
  <xsl:attribute name="border">solid blue</xsl:attribute>
-->
  <xsl:attribute name="min-height">300pt</xsl:attribute>
  <xsl:attribute name="height">300pt</xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="chapter.titlepage.recto.style">
  <xsl:attribute name="padding-top">24pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">36pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="appendix.titlepage.recto.style">
  <xsl:attribute name="text-transform">uppercase</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="component.titlepage.properties">
  <xsl:attribute name="span">all</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="component.title.properties">
  <xsl:attribute name="margin-left">84pt</xsl:attribute>
  <xsl:attribute name="margin-right">84pt</xsl:attribute>
  <xsl:attribute name="min-height">84pt</xsl:attribute>
<!--
  <xsl:attribute name="border">solid red</xsl:attribute>
-->
  <xsl:attribute name="text-align">center</xsl:attribute>
  <xsl:attribute name="line-height">120%</xsl:attribute>
</xsl:attribute-set>




<xsl:include href="fo-header-footer.xsl"/>



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




<xsl:include href="fo-toc.xsl"/>
<xsl:include href="fo-index.xsl"/>






<!-- Section heading properties -->
<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="space-before.minimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6pt</xsl:attribute>
  <xsl:attribute name="line-height">170%</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
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





<xsl:attribute-set name="table.cell.padding">
  <xsl:attribute name="padding-start">3pt</xsl:attribute>
  <xsl:attribute name="padding-end">3pt</xsl:attribute>
  <xsl:attribute name="padding-top">3pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">3pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.properties" use-attribute-sets="formal.object.properties">
  <xsl:attribute name="margin-left">-3pt</xsl:attribute>
  <xsl:attribute name="margin-right">-3pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="informaltable.properties" use-attribute-sets="informal.object.properties">
  <xsl:attribute name="margin-left">-3pt</xsl:attribute>
  <xsl:attribute name="margin-right">-3pt</xsl:attribute>
</xsl:attribute-set>

<!-- Expand this template to add properties to any cell's block -->
<xsl:template name="table.cell.block.properties">
  <!-- highlight this entry? -->
  <xsl:choose>
    <xsl:when test="ancestor::thead or ancestor::tfoot">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="hyphenate">false</xsl:attribute>
    </xsl:when>
    <!-- Make row headers bold too -->
    <xsl:when test="ancestor::tbody and 
                    (ancestor::table[@rowheader = 'firstcol'] or
                    ancestor::informaltable[@rowheader = 'firstcol']) and
                    ancestor-or-self::entry[1][count(preceding-sibling::entry) = 0]">
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <xsl:attribute name="hyphenate">false</xsl:attribute>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Returns the table role for the context element -->
<xsl:template name="tabrole">
  <xsl:param name="node" select="."/>

  <xsl:variable name="tgroup" select="$node/tgroup[1] | 
                                      $node/ancestor-or-self::tgroup[1]"/>

  <xsl:variable name="table" 
                select="($node/ancestor-or-self::table | 
                         $node/ancestor-or-self::informaltable)[last()]"/>

  <xsl:variable name="tabrole">
    <xsl:choose>
      <xsl:when test="$table/@role != ''">
        <xsl:value-of select="normalize-space($table/@role)"/>
      </xsl:when>
      <xsl:when test="$tgroup/@role != ''">
        <xsl:value-of select="normalize-space($tgroup/@role)"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="$tabrole"/>
</xsl:template>

<xsl:template name="table.row.properties">

  <xsl:variable name="tabrole">
    <xsl:call-template name="tabrole"/>
  </xsl:variable>

  <xsl:variable name="row-height">
    <xsl:if test="processing-instruction('dbfo')">
      <xsl:call-template name="pi.dbfo_row-height"/>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="$row-height != ''">
    <xsl:attribute name="block-progression-dimension">
      <xsl:value-of select="$row-height"/>
    </xsl:attribute>
  </xsl:if>

  <xsl:variable name="bgcolor">
    <xsl:call-template name="pi.dbfo_bgcolor"/>
  </xsl:variable>

  <xsl:variable
      name="header_count"
      select="count(ancestor::table/thead) +
	      count(ancestor::informaltable/thead)"/>

  <xsl:variable name="rownum">
    <xsl:number from="tgroup" count="row"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$bgcolor != ''">
      <xsl:attribute name="background-color">
        <xsl:value-of select="$bgcolor"/>
      </xsl:attribute>
    </xsl:when>
<!--
    NOTE 2012-05-14 HUGR: Not sure if I need an explicit role tag, or if
    I can just say that all tables are striped, unless they're in sidebars.

    <xsl:when test="$tabrole = 'striped'">
-->
    <xsl:when test="not(ancestor::sidebar)">
      <xsl:if test="($rownum - $header_count) mod 2 = 0">
        <xsl:attribute name="background-color">#D2D2D2</xsl:attribute>
      </xsl:if>
    </xsl:when>
  </xsl:choose>

  <!-- Keep header row with next row -->
  <xsl:if test="ancestor::thead">
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:if>

</xsl:template>




</xsl:stylesheet>
