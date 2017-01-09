<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text" encoding="UTF-8" name="text"/>
    <xsl:output method="xml" encoding="UTF-8" indent="no" omit-xml-declaration="no"/>
    <xsl:include href="download-images_applescript.xsl"/>
    
    <!-- This stylesheet downloads image files referenced in the tei:facsimile element to the local hard drive and adds links to these downloaded images to tei:facsimile -->
    
    <!-- provide the path to a local folder to which all images should be saved -->
    <xsl:param name="p_base-path" select="'/Users/BachPrivat/test_download/'"/>
    <!-- Select an online facsimile based on the position of the tei:graphic children of tei:surface that have an @url beginning with http -->
    <xsl:param name="p_position-facsimile" select="1"/>
    <xsl:param name="p_id-editor" select="'pers_TG'"/>
    <xsl:variable name="vg_id-file" select="tei:TEI/@xml:id"/>
    
    <xsl:template match="/">
        <!-- step 1: construct download instructions -->
        <!-- construct a comma-separated list of urls of online facsimiles -->
        <xsl:variable name="v_image-url">
            <xsl:for-each select="descendant::tei:surface/tei:graphic[starts-with(@url,'http')][$p_position-facsimile]">
                <xsl:value-of select="concat('&quot;',@url,'&quot;')"/>
                <xsl:if test="following::tei:surface">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- construct a comma-sparated list of file names (one for each image), the local path is then handed over and added by the applescript -->
        <xsl:variable name="v_image-local-path">
            <xsl:for-each select="descendant::tei:surface/tei:graphic[starts-with(@url,'http')][1]">
                <xsl:value-of select="concat('&quot;',tokenize(@url,'/')[last()],'&quot;')"/>
                <xsl:if test="following::tei:surface">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
       <xsl:result-document href="{$p_base-path}download-images_{$vg_id-file}.scpt" method="text">
           <xsl:call-template name="t_applescript">
               <xsl:with-param name="p_image-url" select="$v_image-url"/>
               <xsl:with-param name="p_image-local-path" select="$v_image-local-path"/>
               <!--            <xsl:with-param name="p_base-path" select="replace(substring-before(base-uri(),'xml/oclc'),'file:','')"/>-->
               <xsl:with-param name="p_base-path" select="$p_base-path"/>
           </xsl:call-template>
       </xsl:result-document>
        <!-- step 2: replicate the input TEI and add a new tei:graphic child to each tei:surface with a link to the newly-downloaded local file -->
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- replicate all -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add links to downloaded facsimiles -->
    <xsl:template match="tei:surface">
        <xsl:copy>
            <!-- replicate all attributes and child nodes -->
            <xsl:apply-templates select="@*| node()"/>
            <!-- add new child -->
            <xsl:element name="tei:graphic">
                <!-- @xml:id should be added by another transformation -->
                <xsl:attribute name="url" select="concat($p_base-path,tokenize(child::tei:graphic[starts-with(@url,'http')][$p_position-facsimile]/@url,'/')[last()])"/>
                <xsl:copy-of select="child::tei:graphic[starts-with(@url,'http')][$p_position-facsimile]/@mimeType"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- update revisionDesc -->
    <xsl:template match="tei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:text>Added links to local facsimile files for each </xsl:text>
                <tei:gi>surface</tei:gi>
                <xsl:text> element.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>