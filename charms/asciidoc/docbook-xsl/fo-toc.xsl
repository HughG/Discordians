<!--
  Table of Contents styling
-->

<!--
-->

<!DOCTYPE xsl:stylesheet [
<!ENTITY % common.entities SYSTEM "/opt/local/share/xsl/docbook-xsl/common/entities.ent">
%common.entities;
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:param name="bridgehead.in.toc" select="0"/>
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
<xsl:param name="toc.image.filename">../book/Discordians_Title_Backdrop.png</xsl:param>
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
	  <xsl:with-param name="filename" select="$toc.image.filename"/>
	</xsl:call-template>
      </xsl:attribute>
    </fo:external-graphic>
  </fo:block>
</xsl:template>
<xsl:attribute-set name="table.of.contents.titlepage.recto.style">
<!--
  <xsl:attribute name="border">solid orange</xsl:attribute>
-->
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
<!--
    Exclude items from ToC
    http://www.sagehill.net/docbookxsl/TOCcontrol.html#TitlesOutOfToc
-->
<xsl:template match="*[@role = 'NotInToc']" mode="toc" />

</xsl:stylesheet>
