<?xml version="1.0" encoding="UTF-8"?>
<!--
  content-customization-example.xsl - Example XSL Transform Customizations

  Purpose: Demonstrates common XSLT customizations for ePublisher content processing
  Based on: ePublisher XSL transformation patterns (XSLT 1.0)

  Usage:
    1. Copy the actual XSL file from installation that you want to customize
    2. Locate the template or section you want to modify
    3. Apply customization patterns from this example
    4. Save to: Formats\WebWorks Reverb 2.0\Transforms\[filename].xsl
              or Targets\[TargetName]\Transforms\[filename].xsl
              or Formats\Shared\common\pages\[filename].xsl

  Important Notes:
    - ePublisher uses XSLT 1.0 (Microsoft .NET runtime)
    - XSLT 2.0+ features are NOT supported
    - Test all changes thoroughly with AutoMap builds
    - Document all customizations with XML comments

  Common Customizations:
    - Add custom attributes to output
    - Modify element processing
    - Add conditional logic
    - Customize link generation
    - Process custom metadata

  Modified: 2025-01-27 - Example customizations
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:wwdoc="urn:WebWorks-Document"
                xmlns:wwhtml="urn:WebWorks-HTML"
                exclude-result-prefixes="wwdoc wwhtml">

  <!-- Import base templates (example - adjust path as needed) -->
  <!-- <xsl:import href="content-base.xsl"/> -->

  <xsl:output method="html"
              encoding="UTF-8"
              indent="yes"
              doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
              doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

  <!--
    EXAMPLE 1: Add Custom Class to Paragraphs

    Override paragraph template to add custom CSS class
  -->
  <xsl:template match="wwdoc:Para">
    <p>
      <!-- CUSTOM: Add custom class based on paragraph type -->
      <xsl:attribute name="class">
        <xsl:text>paragraph</xsl:text>
        <xsl:if test="@Type">
          <xsl:text> para-</xsl:text>
          <xsl:value-of select="@Type"/>
        </xsl:if>
      </xsl:attribute>

      <!-- Process paragraph content -->
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!--
    EXAMPLE 2: Add Data Attributes for Analytics

    Add data-* attributes to track user interactions
  -->
  <xsl:template match="wwdoc:Link">
    <a>
      <!-- Standard href attribute -->
      <xsl:attribute name="href">
        <xsl:value-of select="@Target"/>
      </xsl:attribute>

      <!-- CUSTOM: Add analytics tracking attributes -->
      <xsl:attribute name="data-link-type">
        <xsl:choose>
          <xsl:when test="starts-with(@Target, 'http')">
            <xsl:text>external</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>internal</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:attribute name="data-link-target">
        <xsl:value-of select="@Target"/>
      </xsl:attribute>

      <!-- Link content -->
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!--
    EXAMPLE 3: Custom Note/Callout Processing

    Add special formatting for note elements
  -->
  <xsl:template match="wwdoc:Note">
    <div>
      <!-- CUSTOM: Add class based on note type -->
      <xsl:attribute name="class">
        <xsl:text>note</xsl:text>
        <xsl:if test="@Type">
          <xsl:text> note-</xsl:text>
          <xsl:value-of select="@Type"/>
        </xsl:if>
      </xsl:attribute>

      <!-- CUSTOM: Add icon based on note type -->
      <div class="note-icon">
        <xsl:choose>
          <xsl:when test="@Type = 'warning'">
            <span class="icon">⚠️</span>
          </xsl:when>
          <xsl:when test="@Type = 'tip'">
            <span class="icon">💡</span>
          </xsl:when>
          <xsl:when test="@Type = 'important'">
            <span class="icon">❗</span>
          </xsl:when>
          <xsl:otherwise>
            <span class="icon">ℹ️</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>

      <!-- Note content -->
      <div class="note-content">
        <xsl:apply-templates/>
      </div>
    </div>
  </xsl:template>

  <!--
    EXAMPLE 4: Add Custom Metadata to Output

    Process custom metadata attributes
  -->
  <xsl:template match="wwdoc:Section">
    <div class="section">
      <!-- CUSTOM: Add section ID for deep linking -->
      <xsl:if test="@ID">
        <xsl:attribute name="id">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:if>

      <!-- CUSTOM: Add custom data attributes from source -->
      <xsl:if test="@CustomAttr">
        <xsl:attribute name="data-custom">
          <xsl:value-of select="@CustomAttr"/>
        </xsl:attribute>
      </xsl:if>

      <!-- Section content -->
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!--
    EXAMPLE 5: Conditional Content Processing

    Show/hide content based on conditions
  -->
  <xsl:template match="wwdoc:ConditionalText">
    <!-- CUSTOM: Only output if condition matches -->
    <xsl:if test="@Condition = 'web' or @Condition = 'all'">
      <span class="conditional conditional-{@Condition}">
        <xsl:apply-templates/>
      </span>
    </xsl:if>
  </xsl:template>

  <!--
    EXAMPLE 6: Custom Table Processing

    Add responsive table wrapper
  -->
  <xsl:template match="wwdoc:Table">
    <!-- CUSTOM: Wrap table in responsive container -->
    <div class="table-responsive">
      <table>
        <!-- CUSTOM: Add custom class based on table type -->
        <xsl:attribute name="class">
          <xsl:text>content-table</xsl:text>
          <xsl:if test="@Type">
            <xsl:text> table-</xsl:text>
            <xsl:value-of select="@Type"/>
          </xsl:if>
        </xsl:attribute>

        <!-- Table content -->
        <xsl:apply-templates/>
      </table>
    </div>
  </xsl:template>

  <!--
    EXAMPLE 7: Add Custom Heading Anchors

    Create linkable heading IDs
  -->
  <xsl:template match="wwdoc:Heading">
    <xsl:variable name="level" select="@Level"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="$level = '1'">h1</xsl:when>
        <xsl:when test="$level = '2'">h2</xsl:when>
        <xsl:when test="$level = '3'">h3</xsl:when>
        <xsl:when test="$level = '4'">h4</xsl:when>
        <xsl:when test="$level = '5'">h5</xsl:when>
        <xsl:otherwise>h6</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$tag}">
      <!-- CUSTOM: Generate anchor ID from heading text -->
      <xsl:attribute name="id">
        <xsl:call-template name="generate-id-from-text">
          <xsl:with-param name="text" select="."/>
        </xsl:call-template>
      </xsl:attribute>

      <!-- CUSTOM: Add class with level -->
      <xsl:attribute name="class">
        <xsl:text>heading heading-level-</xsl:text>
        <xsl:value-of select="$level"/>
      </xsl:attribute>

      <!-- Heading content -->
      <xsl:apply-templates/>

      <!-- CUSTOM: Add permalink icon -->
      <a class="heading-permalink" href="#{generate-id-from-text(.)}">
        <span class="permalink-icon">🔗</span>
      </a>
    </xsl:element>
  </xsl:template>

  <!--
    EXAMPLE 8: Code Block Syntax Highlighting Preparation

    Add language class for syntax highlighting libraries
  -->
  <xsl:template match="wwdoc:CodeBlock">
    <pre>
      <!-- CUSTOM: Add language class for Prism.js or Highlight.js -->
      <xsl:attribute name="class">
        <xsl:text>code-block</xsl:text>
        <xsl:if test="@Language">
          <xsl:text> language-</xsl:text>
          <xsl:value-of select="@Language"/>
        </xsl:if>
      </xsl:attribute>

      <code>
        <xsl:if test="@Language">
          <xsl:attribute name="class">
            <xsl:text>language-</xsl:text>
            <xsl:value-of select="@Language"/>
          </xsl:attribute>
        </xsl:if>

        <!-- Preserve whitespace -->
        <xsl:apply-templates/>
      </code>
    </pre>
  </xsl:template>

  <!--
    EXAMPLE 9: Custom Image Processing

    Add responsive image attributes
  -->
  <xsl:template match="wwdoc:Image">
    <figure class="image-figure">
      <img>
        <!-- Standard attributes -->
        <xsl:attribute name="src">
          <xsl:value-of select="@Source"/>
        </xsl:attribute>

        <xsl:attribute name="alt">
          <xsl:value-of select="@AltText"/>
        </xsl:attribute>

        <!-- CUSTOM: Add responsive image class -->
        <xsl:attribute name="class">
          <xsl:text>content-image responsive-image</xsl:text>
        </xsl:attribute>

        <!-- CUSTOM: Add width/height if specified -->
        <xsl:if test="@Width">
          <xsl:attribute name="width">
            <xsl:value-of select="@Width"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:if test="@Height">
          <xsl:attribute name="height">
            <xsl:value-of select="@Height"/>
          </xsl:attribute>
        </xsl:if>

        <!-- CUSTOM: Add loading="lazy" for performance -->
        <xsl:attribute name="loading">lazy</xsl:attribute>
      </img>

      <!-- CUSTOM: Add caption if present -->
      <xsl:if test="@Caption">
        <figcaption>
          <xsl:value-of select="@Caption"/>
        </figcaption>
      </xsl:if>
    </figure>
  </xsl:template>

  <!--
    EXAMPLE 10: Custom List Processing

    Add custom markers and styling to lists
  -->
  <xsl:template match="wwdoc:List">
    <xsl:choose>
      <xsl:when test="@Type = 'ordered'">
        <ol>
          <!-- CUSTOM: Add custom numbering style -->
          <xsl:if test="@NumberStyle">
            <xsl:attribute name="class">
              <xsl:text>list-</xsl:text>
              <xsl:value-of select="@NumberStyle"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </ol>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <!-- CUSTOM: Add custom bullet style -->
          <xsl:if test="@BulletStyle">
            <xsl:attribute name="class">
              <xsl:text>list-</xsl:text>
              <xsl:value-of select="@BulletStyle"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    HELPER TEMPLATES
  -->

  <!--
    Helper: Generate ID from text
    Converts text to valid HTML ID (lowercase, hyphens, no special chars)
  -->
  <xsl:template name="generate-id-from-text">
    <xsl:param name="text"/>
    <xsl:variable name="lowercase" select="translate($text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    <xsl:variable name="normalized" select="translate($lowercase, ' !@#$%^&amp;*()_+=[]{}|;:,./&lt;&gt;?', '------------------------------')"/>
    <xsl:value-of select="translate($normalized, '--', '-')"/>
  </xsl:template>

  <!--
    Helper: Format date/time
    Simple date formatting example
  -->
  <xsl:template name="format-datetime">
    <xsl:param name="datetime"/>
    <!-- Basic formatting - customize as needed -->
    <xsl:value-of select="$datetime"/>
  </xsl:template>

  <!--
    Helper: Check if string starts with
    XSLT 1.0 doesn't have starts-with function in all contexts
  -->
  <xsl:template name="starts-with">
    <xsl:param name="string"/>
    <xsl:param name="prefix"/>
    <xsl:value-of select="substring($string, 1, string-length($prefix)) = $prefix"/>
  </xsl:template>

  <!--
    NOTES:

    - This is an EXAMPLE file showing common XSLT customization patterns
    - Copy the actual XSL file from installation before modifying
    - ePublisher uses XSLT 1.0 only (no 2.0+ features)
    - Test thoroughly with AutoMap builds
    - Document all changes with XML comments
    - Validate XML output for well-formedness
    - Consider performance impact of complex transformations
    - Use xsl:import or xsl:include to modularize customizations

    Debugging Tips:
    - Use <xsl:message> for debug output
    - Check ePublisher build log for transformation errors
    - Validate XPath expressions carefully
    - Test with minimal content first
    - Compare output with installation defaults

  -->

</xsl:stylesheet>
