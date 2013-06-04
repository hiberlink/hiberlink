#!/usr/bin/python -i

import re
import cPickle

lre = re.compile("http://(?!(xxx.lanl.gov|(www.)?ar[xX]iv.org))")
lre2 = re.compile('(.+)\.pdf\.xml:.*(http://[^ <$"]+)')

f = file('links.txt')
l = f.readline()

links = {}
broken = []
ttl = 0

while l:
    # check if we have a on internal link
    m = lre.search(l)
    if m:
        m = lre2.search(l)
        if m:
            (fn, uri) = m.groups()
            try:
                links[fn][uri] = 1
            except:
                links[fn] = {uri:1}
        else:
            broken.append(l)
    l = f.readline()

srlzd = cPickle.dumps(links)
fh = file('serialized-links.pkl', 'w')
fh.write(srlzd)
fh.close()

srlzd = cPickle.dumps(broken)
fh = file('serialized-broken.pkl', 'w')
fh.write(srlzd)
fh.close()



