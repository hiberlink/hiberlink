#!/usr/bin/python -i

# argv[1] : pdffilelist file path
# argv[2] : output directory for links (assumed directory already created)

import os
import re
import sys
import urllib2
import cPickle
from lxml import etree


SPOONLIB_URLINTEXT_PAT = re.compile(ur'(((http|ftp|https):\/{2})+(([0-9a-z_-]+\.)+(aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mn|mn|mo|mp|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|nom|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ra|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw|arpa)(:[0-9]+)?((\/([~0-9a-zA-Z\#\+\%@\.\/_-]+))?(\?[0-9a-zA-Z\+\%@\/&\[\];=_-]+)?)?))\b',re.IGNORECASE)


GRUBER_URLINAHREF_PAT = re.compile(ur'(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?\xab\xbb\u201c\u201d\u2018\u2019]))',re.IGNORECASE)



arxRe = re.compile('http://((www.)?ar[xX]iv.org|xxx.lanl.gov)')
lre2 = re.compile('http[s]?://[^ $"]+')




outfName = 'links-filter-LTG-prototype-v1-' + os.path.basename(sys.argv[1]) + '.txt'
outf = os.path.join('.', outfName)
out = file(outf, 'w')


# change your XML file folder here
pdffilelist = sys.argv[1]
files = open(pdffilelist)
while 1:
	fileStack = files.readlines(100000)
	if not fileStack:
		break
	for pdfFile in fileStack:
		pdfFile = pdfFile.replace('\n', '')
		pdfFile = pdfFile.replace("\n", '')
        	fn = os.path.basename(pdfFile)
		f = file(pdfFile)
        	# if it is file (assumed to be XML)
        	data=f.read()
        	f.close()
        	try:
 	           	dom = etree.XML(data)
        	except:
            		continue

    # These are likely to be real
        	aelms = dom.xpath('//a/@href')

    # and absolute links within arxiv
        	aelms = filter(lambda x: not arxRe.search(x), aelms)

        	mlinks = {}
        	for ae in aelms:
            		for mgroups in GRUBER_URLINAHREF_PAT.findall(ae):
                		ae = mgroups[0]
                		mlinks[ae] = 1
    
        # These are likely to be broken due to new lines etc
        	text = ''.join(dom.xpath('//text()'))
       		text = text.replace('\n', ' ')
        	text = re.sub(' +',' ',text)
        	text = text.replace(' /', '/')
        	text = text.replace('- ', '-')
        	text = text.replace(' -', '-')
        	text = text.replace(' .htm', '.htm')
        	text = text.replace(' .html', '.html')
        	text = text.replace(' .pdf', '.pdf')
        	text = text.replace('www. ','www.')
    

        	for mgroups in SPOONLIB_URLINTEXT_PAT.findall(text):
            		l = mgroups[0]
            		mlinks[l] = 1

        	for l in mlinks.keys():
            		if not l[-1] in ['-', '~', '.', '=', '&']:
                		out.write('%s: %s\n' % (fn, l.encode('utf-8')))
                		out.flush()



out.close()
