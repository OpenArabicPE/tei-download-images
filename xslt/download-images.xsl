<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:output method="text" encoding="UTF-8" name="text"/>
    <xsl:output method="xml" encoding="UTF-8" indent="no" omit-xml-declaration="no"/>
    <xsl:include href="download-images_applescript.xsl"/>
    <xsl:include href="download-images_shell-script.xsl"/>
    
    <!-- This stylesheet downloads image files referenced in the tei:facsimile element to the local hard drive and adds links to these downloaded images to tei:facsimile -->
    <!-- WARNING: make sure that you have the rights to download the images before running this script -->
    
    <!-- file path on local system:
        folder of edition/
        images/
        folder for volume/
        folder for holding institution/
        image
    -->
    
    <!-- provide the path to a local folder to which all images should be saved -->
    <!-- NOTE: at least in macOS Mojave, applescript seems not to work with relative paths -->
    <xsl:param name="p_base-path" select="'/BachUni/BachBibliothek/GitHub/OpenArabicPE/journal_al-zuhur'"/>
    <xsl:param name="p_folder-images" select="'images'"/>
    <!-- this is going to be the name of the subfolder for the downloaded images -->
    <xsl:param name="p_folder-holding-institution" select="'tuebingen'"/>
    <!-- Select an online facsimile based on the position of the tei:graphic children of tei:surface that have an @url beginning with http. There might be better selectors that should be implemented in future versions -->
    <xsl:param name="p_position-facsimile" select="1"/>
    <!-- @xml:id specifying a responsible editor -->
    <xsl:include href="../../oxygen-project/OpenArabicPE_parameters.xsl"/>
<!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:variable name="vg_id-file" select="tei:TEI/@xml:id"/>
    <xsl:variable name="v_source" select="tei:TEI/tei:teiHeader//tei:sourceDesc/tei:biblStruct[1]"/>
    <xsl:variable name="v_id-oclc" select="$v_source//tei:idno[@type='OCLC'][1]"/>
    <xsl:variable name="v_volume" select="$v_source//tei:biblScope[@unit='volume']/@from"/>
    <xsl:variable name="v_folder-volume">
        <xsl:value-of select="concat('oclc_',$v_id-oclc,'-v_',$v_volume)"/>
    </xsl:variable>
    <xsl:variable name="v_file-name">
        <xsl:variable name="v_issue">
            <xsl:choose>
                <xsl:when test="$v_source//tei:biblScope[@unit='issue']/@from != $v_source//tei:biblScope[@unit='issue']/@to">
                    <xsl:value-of select="$v_source//tei:biblScope[@unit='issue']/@from"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="$v_source//tei:biblScope[@unit='issue']/@to"/>
                </xsl:when>
                <xsl:when test="$v_source//tei:biblScope[@unit='issue']/@from = $v_source//tei:biblScope[@unit='issue']/@to">
                    <xsl:value-of select="$v_source//tei:biblScope[@unit='issue']/@from"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat('oclc_',$v_id-oclc,'-v_',$v_volume,'-i_',$v_issue)"/>
    </xsl:variable>
    <xsl:variable name="v_local-path" select="concat($p_base-path, '/', $p_folder-images, '/', $v_folder-volume, '/', $p_folder-holding-institution, '/')"/>
    
    <!-- construct urls of online facsimiles -->
    <xsl:variable name="v_image-url">
        <xsl:for-each select="tei:TEI/tei:facsimile/tei:surface/tei:graphic[starts-with(@url,'http')][$p_position-facsimile]">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:variable>
    <!-- construct a  list of file names (one for each image) -->
    <xsl:variable name="v_image-local-name">
        <xsl:for-each select="tei:TEI/tei:facsimile/tei:surface/tei:graphic[starts-with(@url,'http')][$p_position-facsimile]">
            <xsl:variable name="v_file-name-image">
                <!-- this needs to be changed to a corresponding page number! either by pulling the page number from the corresponding <pb/> or by counting the preceding <tei:surface> nodes -->
                <!-- tokenize the path to the online copy and select the last bit that is most likely a file name -->
                <xsl:value-of select="tokenize(@url,'/')[last()]"/>
            </xsl:variable>
            <xsl:variable name="v_page" select="count(parent::tei:surface/preceding-sibling::tei:surface) + 1"/>
            <xsl:copy>
                <xsl:attribute name="url">
                    <xsl:choose>
                        <!-- check if file name contains a suffix indicating the file type -->
                        <xsl:when test="matches($v_file-name-image,'\.(jpg|jpeg|tiff|tif|png)$')">
                            <xsl:variable name="v_file-type" select="replace($v_file-name-image,'^.+\.(\w+)$', '$1')"/>
                            <xsl:value-of select="concat($v_file-name,'-img_',$v_page, '.', $v_file-type)"/>
                        </xsl:when>
                        <!-- check for php attributes (used by HathiTrust; e.g. image?id=umn.319510029968624;seq=171) -->
                        <xsl:when test="matches($v_file-name-image,'id=.[a-z]+\.\d+;seq=\d+$')">
                            <xsl:analyze-string select="$v_file-name-image" regex="id=(.[a-z]+)\.(\d+);seq=(\d+)$">
                                <xsl:matching-substring>
                                    <xsl:value-of select="concat(regex-group(1),'-',regex-group(2),'-img_',regex-group(3),'.jpg')"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    
    
    <xsl:template match="/">
        <!-- step 1: construct download instructions -->
         <!-- construct apple script -->
       <xsl:result-document href="{$v_local-path}/download-images_{$vg_id-file}.scpt" method="text">
           <xsl:call-template name="t_applescript">
               <!-- construct a comma separated list of file names from $v_image-url -->
               <xsl:with-param name="p_image-url">
                   <xsl:for-each select="$v_image-url/descendant-or-self::tei:graphic">
                       <xsl:value-of select="concat('&quot;',@url,'&quot;')"/>
                       <xsl:if test="following::tei:graphic">
                           <xsl:text>, </xsl:text>
                       </xsl:if>
                   </xsl:for-each>
               </xsl:with-param>
               <xsl:with-param name="p_image-local-name" >
                   <xsl:for-each select="$v_image-local-name/descendant-or-self::tei:graphic">
                       <xsl:value-of select="concat('&quot;',@url,'&quot;')"/>
                       <xsl:if test="following::tei:graphic">
                           <xsl:text>, </xsl:text>
                       </xsl:if>
                   </xsl:for-each>
               </xsl:with-param>
               <xsl:with-param name="p_base-path" select="$v_local-path"/>
           </xsl:call-template>
       </xsl:result-document>
        <xsl:result-document href="{$v_local-path}/download-images_{$vg_id-file}.sh" method="text">
            <xsl:call-template name="t_curl-script">
                <xsl:with-param name="p_image-url" select="$v_image-url"/>
                <xsl:with-param name="p_image-local-name" select="$v_image-local-name"/>
                <xsl:with-param name="p_base-path" select="$v_local-path"/>
            </xsl:call-template>
        </xsl:result-document>
        <!-- step 2: replicate the input TEI and add a new tei:graphic child to each tei:surface with a link to the newly-downloaded local file -->
        <xsl:result-document href="_output/local-facs/{$vg_id-file}.TEIP5.xml">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <!-- replicate all -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add links to downloaded facsimiles -->
    <xsl:template match="tei:surface">
        <xsl:variable name="v_position" select="count(preceding-sibling::tei:surface)+1"/>
        <xsl:copy>
            <!-- replicate all attributes and child nodes -->
            <xsl:apply-templates select="@*| node()"/>
            <!-- add new child -->
            <xsl:element name="tei:graphic">
                <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                <!-- @xml:id should be added by another transformation -->
                <xsl:attribute name="xml:id" select="concat(@xml:id,'-g_',count(tei:graphic)+1)"/>
                <!-- add path to local file (to be) downloaded with either the shell or the apple script -->
                <xsl:attribute name="url" select="concat($v_local-path,$v_image-local-name/descendant-or-self::tei:graphic[$v_position]/@url)"/>
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
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Added links to local facsimile files for each </xsl:text>
                <tei:gi>surface</tei:gi>
                <xsl:text> element.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>