<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Our output is a fragment, so we don't want an XML decl. -->
  <xsl:output omit-xml-declaration="yes"/>

  <!-- Version info param with default value. -->
  <xsl:param name="version-info">
    <xsl:text>[ERROR: Failed to derive version information]</xsl:text>
  </xsl:param>

  <!--
      Fill in the version information.  I'd just do this with a system entity
      in the docinfo XML file, except it's not parsed as a valid XML document
      with its own DOCTYPE, just a fragment containing a sequence of elements
      (matching the content of DocBook's articleinfo or bookinfo).
  -->
  <xsl:template match="my-version-info">
    <xsl:value-of select="$version-info"/>
  </xsl:template>

  <!--
      Discard the dummy root element.  We need a well-formed document as input
      but want to output just a sequence of elements.
  -->
  <xsl:template match="dummy-root">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <!-- Identity transform for everything else. -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
