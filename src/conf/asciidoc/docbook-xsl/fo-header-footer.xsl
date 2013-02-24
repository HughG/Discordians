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
    TODO 2012-03-24 hughg: Proper background image for header.

    TODO 2012-03-24 hughg: Proper background image for outer margin.

    TODO 2012-03-24 hughg: ... or combine the above two into page background?

    TODO 2012-03-24 hughg: Background image for page numbers.

    TODO 2012-03-24 hughg: Leading zeros in page numbers.

    TODO 2012-03-24 hughg: Footer rule.

    TODO 2012-03-31 hughg: Try doing page numbers using a margin note?
-->

<!DOCTYPE xsl:stylesheet [
<!ENTITY % common.entities SYSTEM "/opt/local/share/xsl/docbook-xsl/common/entities.ent">
%common.entities;
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="header.column.widths">0 1 0</xsl:param>
<xsl:param name="header.image.filename">../book/header_strip.png</xsl:param>
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
<!--
	<xsl:attribute name="margin-{$direction.align.start}">-0.125in</xsl:attribute>
	<xsl:attribute name="margin-{$direction.align.end}">-5in</xsl:attribute>
	<fo:external-graphic content-height="0.6in" content-width="7.2in">
	  <xsl:attribute name="src">
	    <xsl:call-template name="fo-external-image">
	      <xsl:with-param name="filename" select="$header.image.filename"/>
	    </xsl:call-template>
	  </xsl:attribute>
	</fo:external-graphic>
-->
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and ($sequence = 'odd' or $sequence = 'first')
                      and $position='right'">
<!--
	<xsl:attribute name="margin-{$direction.align.end}">-0.6in</xsl:attribute>
	<fo:external-graphic content-height="0.6in" content-width="7.2in">
	  <xsl:attribute name="src">
	    <xsl:call-template name="fo-external-image">
	      <xsl:with-param name="filename" select="$header.image.filename"/>
	    </xsl:call-template>
	  </xsl:attribute>
	</fo:external-graphic>
-->
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

<xsl:param name="footer.rule" select="0"/>
<!--
<xsl:attribute-set name="footer.table.properties">
  <xsl:attribute name="border">solid green</xsl:attribute>
</xsl:attribute-set>
-->
<xsl:attribute-set name="footer.content.properties">
  <xsl:attribute name="font-family">LibertinageBasicSC</xsl:attribute>
</xsl:attribute-set>
<!--
<xsl:param name="footer.column.widths">1 8 1</xsl:param>
-->
<xsl:template name="footer.table">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <!-- default is a single table style for all footers -->
  <!-- Customize it for different page classes or sequence location -->

  <xsl:choose>
      <xsl:when test="$pageclass = 'index'">
          <xsl:attribute name="margin-{$direction.align.start}">0pt</xsl:attribute>
      </xsl:when>
  </xsl:choose>

  <xsl:variable name="column1">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">1</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">1</xsl:when>
      <xsl:otherwise>3</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="column3">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">3</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">3</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="candidate">
    <fo:table xsl:use-attribute-sets="footer.table.properties">
      <xsl:call-template name="foot.sep.rule">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="$sequence"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
      <fo:table-column column-number="1">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="$column1"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="2">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="2"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="3">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="$column3"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>

      <fo:table-header>
        <fo:table-row>
          <xsl:attribute name="block-progression-dimension.minimum">
	    3pt
          </xsl:attribute>
          <fo:table-cell text-align="start"
                         display-align="after"
			 number-columns-spanned="3">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
	    <fo:block margin-left="8pt"
		      margin-right="8pt"
		      border="1pt ridge silver">
<!--
              <xsl:text>Bob</xsl:text>
-->
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-header>

      <fo:table-body>
        <fo:table-row>
          <xsl:attribute name="block-progression-dimension.minimum">
            <xsl:value-of select="$footer.table.height"/>
          </xsl:attribute>
          <fo:table-cell text-align="start"
                         display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.start"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="center"
                         display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="'center'"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="end"
                         display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.end"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:variable>

  <!-- Really output a footer? -->
  <xsl:choose>
    <xsl:when test="$pageclass='titlepage' and $gentext-key='book'
                    and $sequence='first'">
      <!-- no, book titlepages have no footers at all -->
    </xsl:when>
    <xsl:when test="$sequence = 'blank' and $footers.on.blank.pages = 0">
      <!-- no output -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$candidate"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

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
<!--
		      and $sequence = 'odd'
-->
	<xsl:attribute name="margin-{$direction.align.end}">-0.6in</xsl:attribute>
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$double.sided != 0
		      and ($sequence = 'odd' or $sequence = 'first')
		      and $position='center'">
<!--
		      and ($sequence = 'odd')
-->
	<xsl:if test="$gentext-key='Chapter' or $gentext-key='chapter'">
	  <xsl:call-template name="gentext">
	    <xsl:with-param name="key" select="$gentext-key"/>
	  </xsl:call-template> 
	  <xsl:text> </xsl:text>
	  <xsl:apply-templates select="." mode="label.markup"/>
	  <xsl:text> &#x2022; </xsl:text>
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

</xsl:stylesheet>
