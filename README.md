---
title: "read me: OpenArabicPE/tei-download-images"
author: Till Grallert
date: 2017-03-17 11:51:29 +0100
---

This repository contains a set of XSLT stylesheets that provide the means to download digital facsimiles from the links provided in TEI XML files. If you wish to use them, make sure the licence of the images allows for download to your local machine. The main stylesheet `xslt/download-images.xsl` will do the following:

1. Create a list of URLs to images to be downloaded based on the `<tei:facsimile>` child of `<tei:TEI>`.
2. Create a list of local files names for the images based on their URL.
3. Generate a shell script to download the images and save them under their local file names using the `$curl` command.
4. Generate an applescript wrapping the curl script for those uncomfortable using the terminal.
5. Generate a copy of the original TEI file with additional links to the downloaded images.

In order to actually download the facsimiles, either run the shell script or the applescript.

**NOTE**: the XSLT doesn't yet deal with IIIF hosted facsimiles.