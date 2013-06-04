#!/usr/bin/python -i

import commands
import sys, os

base = './pdfs'

dirs = os.listdir(base)
dirs.sort(key=lambda x: '19' + x if x[0] == '9' else '20' + x )

for d in dirs:
    nd = os.path.join(base, d)
    files = os.listdir(nd)
    for f in files:
        fn = os.path.join(nd, f)
        commands.getoutput('pdftohtml -xml %s ./xml/%s/%s' % (fn, d, f))
        sys.stdout.write('.')
        sys.stdout.flush()
                           

