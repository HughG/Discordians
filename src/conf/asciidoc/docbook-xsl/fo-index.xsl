<!--
    Index styling
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

<!--
    Index
-->
<!--
    Three columns in index
-->
<xsl:param name="column.count.index" select="3"/>
<xsl:param name="column.gap.index">10pt</xsl:param>
<!--
    Allow specialised indices, for "Index of Charms"
-->
<xsl:param name="index.on.type" select="1"/>
<!--
    Index styling
-->
<xsl:attribute-set name="index.titlepage.recto.style">
  <xsl:attribute name="padding-top">0pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
  <xsl:attribute name="margin-top">0pt</xsl:attribute>
  <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
  <xsl:attribute name="font-size">18pt</xsl:attribute>
  <xsl:attribute name="text-transform">uppercase</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="index.div.title.properties">
  <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="index.entry.properties">
  <xsl:attribute name="text-align-last">justify</xsl:attribute>
<!--
  <xsl:attribute name="border">dashed orange</xsl:attribute>
-->
</xsl:attribute-set>
<xsl:param name="index.term.separator">
    <fo:leader leader-pattern="space"
	       keep-with-next.within-line="always"/>
</xsl:param>
<!--
    Template overrides to make fo:leader work with FOP.
-->
<xsl:template match="indexterm" mode="reference">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="position" select="0"/>
  <xsl:param name="separator" select="''"/>

  <xsl:variable name="term.separator">
    <xsl:call-template name="index.separator">
      <xsl:with-param name="key" select="'index.term.separator'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="range.separator">
    <xsl:call-template name="index.separator">
      <xsl:with-param name="key" select="'index.range.separator'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="number.separator">
    <xsl:call-template name="index.separator">
      <xsl:with-param name="key" select="'index.number.separator'"/>
    </xsl:call-template>
  </xsl:variable>

<!--
    NOTE 2012-03-26 HUGR: Use copy-of instead of value-of here, otherwise we
    can't use fo:leader in the separators, because it has a value of "".
-->
  <xsl:choose>
    <xsl:when test="$separator != ''">
      <xsl:copy-of select="$separator"/>
    </xsl:when>
    <xsl:when test="$position = 1">
      <xsl:copy-of select="$term.separator"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$number.separator"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="@zone and string(@zone)">
      <xsl:call-template name="reference">
        <xsl:with-param name="zones" select="normalize-space(@zone)"/>
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="ancestor::*[contains(local-name(),'info') and not(starts-with(local-name(),'info'))]">
      <xsl:call-template name="info.reference">
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="id">
        <xsl:call-template name="object.id"/>
      </xsl:variable>

      <fo:basic-link internal-destination="{$id}"
                     xsl:use-attribute-sets="index.page.number.properties">
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>

      <xsl:if test="key('endofrange', $id)[&scope;]">
        <xsl:apply-templates select="key('endofrange', $id)[&scope;][last()]"
                             mode="reference">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="separator" select="$range.separator"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="index.separator">
  <xsl:param name="key" select="''"/>
  <xsl:param name="lang">
    <xsl:call-template name="l10n.language"/>
  </xsl:param>

<!--
    NOTE 2012-03-26 HUGR: Test using the implicit "boolean()" call of the
    xsl:when element, instead of the expression "index.foo.separator != ''".
    For a separator which is a string, the result is the same.  For one which
    is a node-set, such as

      <xsl:text> </xsl:text>
      <fo:leader leader-pattern="dots"/>
      <xsl:text> </xsl:text>

    the string comparison will convert it to an empty string and so the
    inequality will be false, so the override is skipped; on the other hand,
    falling straight through to the implicit call to boolean will find a
    non-empty node set, and so return true, allowing it to override.
-->
  <xsl:choose>
    <xsl:when test="$key = 'index.term.separator'">
      <xsl:choose>
        <!-- Use the override if not blank -->
        <xsl:when test="$index.term.separator">
          <xsl:copy-of select="$index.term.separator"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="gentext.template">
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="context">index</xsl:with-param>
            <xsl:with-param name="name">term-separator</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$key = 'index.number.separator'">
      <xsl:choose>
        <!-- Use the override if not blank -->
        <xsl:when test="$index.number.separator">
          <xsl:copy-of select="$index.number.separator"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="gentext.template">
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="context">index</xsl:with-param>
            <xsl:with-param name="name">number-separator</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$key = 'index.range.separator'">
      <xsl:choose>
        <!-- Use the override if not blank -->
        <xsl:when test="$index.range.separator">
          <xsl:copy-of select="$index.range.separator"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="gentext.template">
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="context">index</xsl:with-param>
            <xsl:with-param name="name">range-separator</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
