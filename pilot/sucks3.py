#!/usr/bin/python -i

import commands
import sys,os
from lxml import etree

# first pull in manifest file

manifest = "pdf/arXiv_pdf_manifest.xml"

tree = etree.parse(file(manifest))
dom = tree.getroot()

# pull file names with xpath

filelist = dom.xpath('/arXivPDF/file/filename/text()')
md5list = dom.xpath('/arXivPDF/file/content_md5sum/text()')

# Now iterate through files

for f in filelist:
    # Check if file exists
    if not os.path.exists(f):
        # use perl script to download file
        print "Downloading: %s" % f
        resp = commands.getoutput("perl ./get-rpb-object.pl -k %s" % f)
        print resp
    else:
        print "FOUND: %s" % f
