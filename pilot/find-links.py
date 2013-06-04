#!/usr/bin/python -i

import os
import re
import sys
import urllib2
import cPickle
from lxml import etree


GRUBER_URLINTEXT_PAT = re.compile(ur'(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?\xab\xbb\u201c\u201d\u2018\u2019]))')

arxRe = re.compile('http://((www.)?ar[xX]iv.org|xxx.lanl.gov)')
lre2 = re.compile('http[s]?://[^ $"]+')

links = cPickle.load(file('serialized-links.pkl'))
k = links.keys()
k = filter(lambda x: x[:6] != 'xml/10', k)
k.sort()

out = file('links-filter.txt', 'w')
brkn = file('links-filter-broken.txt', 'w')


for fn in k:
    # Just process right here
    f= file(fn + '.pdf.xml')
    data=f.read()
    f.close()
    try:
        dom = etree.XML(data)
    except:
        brkn.write('%s\n' % fn)
        brkn.flush()
        continue
    # These are likely to be real
    aelms = dom.xpath('//a/@href')
    # filter relative links within arxiv
    aelms = filter(lambda x: x[:4] == 'http', aelms)
    # and absolute links within arxiv
    aelms = filter(lambda x: not arxRe.search(x), aelms)
    mlinks = {}
    for ae in aelms:
        mlinks[ae] = 1
    
    # These are likely to be broken due to new lines etc
    text = ' '.join(dom.xpath('//text()'))
    text = text.replace('  ', ' ')
    text = text.replace(' /', '/')
    text = text.replace('/ ', '/')
    text = text.replace('- ', '-')
    text = text.replace(' -', '-')
    text = text.replace(' .htm', '.htm')
    text = text.replace(' .pdf', '.pdf')

    for mgroups in GRUBER_URLINTEXT_PAT.findall(text):
        l = mgroups[0]
        mlinks[l] = 1

    for l in mlinks.keys():
        if not l[-1] in ['-', '~', '.', '=', '&']:
            out.write('%s: %s\n' % (fn, l.encode('utf-8')))
            out.flush()

out.close()
