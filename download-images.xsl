<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:include href="download-images_applescript.xsl"/>
    
    <!-- This stylesheet downloads image files referenced in the tei:facsimile element to the local hard drive -->
    
    <xsl:template match="/">
        <xsl:variable name="v_image-url">
            <xsl:for-each select="descendant::tei:surface/tei:graphic[1]">
                <xsl:value-of select="concat('&quot;',@url,'&quot;')"/>
                <xsl:if test="following::tei:surface">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v_image-local-path">
            <xsl:for-each select="descendant::tei:surface/tei:graphic[2]">
                <xsl:value-of select="concat('&quot;', replace(@url,'\.\./',''),'&quot;')" />
                <xsl:if test="following::tei:surface">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:call-template name="t_applescript">
           <xsl:with-param name="p_image-url" select="$v_image-url"/>
           <xsl:with-param name="p_image-local-path" select="$v_image-local-path"/>
<!--            <xsl:with-param name="p_base-path" select="replace(substring-before(base-uri(),'xml/oclc'),'file:','')"/>-->
            <xsl:with-param name="p_base-path" select="'/Volumes/Dessau HD/BachUni/BachSources/mawaqif/'"/>
       </xsl:call-template>
    </xsl:template>
    
   <!-- <xsl:template match="tei:surface/tei:graphic[2]">
        <xsl:result-document href="{@url}">
            <xsl:value-of select="preceding-sibling::tei:graphic[1]/@url"/>
        </xsl:result-document>
    </xsl:template>-->
    
</xsl:stylesheet>