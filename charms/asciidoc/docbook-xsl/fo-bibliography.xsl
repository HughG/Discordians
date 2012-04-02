<!--
    Bibliography styling.
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

<xsl:template name="xref.xreflabel">
  <!-- called to process an xreflabel...you might use this to make  -->
  <!-- xreflabels come out in the right font for different targets, -->
  <!-- for example. -->
  <xsl:param name="target" select="."/>

  <xsl:if test="$target/ancestor::bibliography">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:if>
  <xsl:value-of select="$target/@xreflabel"/>
</xsl:template>

<xsl:attribute-set name="biblioentry.properties" use-attribute-sets="normal.para.spacing">
  <xsl:attribute name="start-indent">0pt</xsl:attribute>
  <xsl:attribute name="text-indent">18pt</xsl:attribute>
</xsl:attribute-set>

<!--
    The default template adds a surrounding block with a 1in start-indent,
    which I don't want.
-->
<xsl:template match="abstract" mode="bibliomixed.mode">
  <xsl:apply-templates mode="bibliomixed.mode"/>
</xsl:template>
</xsl:stylesheet>
