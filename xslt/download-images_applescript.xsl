<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    >
    <xsl:output method="xml"  version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"  name="xml"/>
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"  name="text"/>
    
    <!-- This helper stylesheet builds an applescript to download images (or any link) from the net to a folder -->
    <!-- The stylesheet can be called from other XSLT stylesheets which have to supply the data for the target folder, the link list, and the list of file names to be generated
        $p_base-path must be a literal string
        $p_image-url and $p_image-local-name are comma-separated lists of values in double quotes -->
    
    
    
    <xsl:template name="t_applescript">
        <xsl:param name="p_image-url"/>
        <xsl:param name="p_image-local-name"/>
        <xsl:param name="p_base-path"/>
        
        <![CDATA[
set vImgUrl to {]]><xsl:value-of select="$p_image-url" disable-output-escaping="no"/><![CDATA[}]]>
        <![CDATA[
set vImgPath to {]]><xsl:value-of select="$p_image-local-name"/><![CDATA[}]]>
        <![CDATA[
set vBasePath to {"]]><xsl:value-of select="$p_base-path"/><![CDATA["}]]>
        <![CDATA[

set vErrors to {}

repeat with Y from 1 to (number of items) of vImgUrl
	set vImgUrlSelected to item Y of vImgUrl
	set vImgPathSelected to item Y of vImgPath
	set vFileName to vImgPathSelected 
	
	try
		
		do shell script "curl -L " & vImgUrlSelected & " -o '" & vBasePath & vFileName & "' " 
	on error
		set end of vErrors to vImgUrlSelected
		set the clipboard to vErrors as text
	end try
	
end repeat

]]>

        <!-- tell application "TextEdit"
	make new document
	set text of document 1 to (the clipboard as text)
	save document 1 in vFolder1 & "/postcard-errors.txt"
end tell -->

    </xsl:template>
  
</xsl:stylesheet>