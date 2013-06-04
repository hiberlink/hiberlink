#!/usr/bin/python -i

import urllib
import cPickle
import sys
import sqlite3
import re
import urlparse
import socket

socket.setdefaulttimeout(120)

baseurl = "http://mementoproxy.lanl.gov/aggr/timemap/link/"


# URL Sanity Filtering
blacklist = ['localhost', 'arxiv.org', 'www.arxiv.org', 'xxx.lanl.gov', 'www-spires.slac.stanford.edu']

tlds = file('tlds-alpha-by-domain.txt')
data = tlds.readlines()
tlds.close()
# strip header line
data = data[1:]
tldlist = [x.lower()[:-1] for x in data]

# Load up our URLs
fh = file('links-filter.txt')
data = fh.readlines()
fh.close()

# reverse the list so we meet in the middle, saving a week of processing
# ... hopefully :P
data.reverse()

# Initialize cache
conn = sqlite3.connect('./url-tms.sqlite')
cur = conn.cursor()

x = len(data)+1
for v in data:

    # We're ignoring fn for now, will re-walk file in analysis
    (fn, v) = v.split(':', 1)

    sys.stdout.flush()
    x -= 1
    # chomp
    v = v.strip()
    
    #sanity check the URL
    if not v.lower().startswith('http://') and not v.lower().startswith('https://'):
        v = 'http://' + v

    # Maybe append trailing slash
    if v.count('/') == 2:
        v = v + '/'
    
    try:
        bits = urlparse.urlparse(v)
    except:
        print 'failed to parse: ' + v
        continue
    # check if known TLD
    if not bits.netloc:
        print 'no host: ' + v
        continue
    else:
        host = bits.netloc
        if host.find(':') > -1:
            (host,port) = host.split(':', 1)
            if not port.isdigit():
                print 'broken port: ' + v
                continue
        host = host.lower()
            
    if host in blacklist:
        print 'blacklist: ' + v
        continue
    nb = host.split('.')
    if not nb[-1] in tldlist and not nb[-1].isdigit():
        print 'no tld: ' + v
        continue 
    
    try:
        res = cur.execute('select * from timemaps where url=?', (v,))
        data = res.fetchall()
        if data:
            # already done
            continue
    except:
        continue
    
    # ----- Now we're ready to pull down timemap
    sys.stdout.write("--->" + v)
    sys.stdout.flush()
    
    try:
        sys.stdout.write(' TM')
        sys.stdout.flush()
        fh = urllib.urlopen(baseurl + v)
    except:
        # XXX Store broken link
        continue
    data = fh.read()
    fh.close()
    
    if fh.code == 404:
        archived = 0
    else:
        archived = 1
        oh = file('timemaps2/%09d.lnk' % x, 'w')
        oh.write("%s\n" % v)
        oh.write(data)
        oh.close()
    
    exist = 0
    try:
        sys.stdout.write(' ORIG')
        sys.stdout.flush()
        fh = urllib.urlopen(v)
        data = fh.read()
        fh.close()
        if fh.code < 400:
            exist = 1
    except:
        pass

    sys.stdout.write(' DB\n')
    sys.stdout.flush()
    cur.execute('insert into timemaps values (?,?,?,?)', (v, x, exist, archived))
    conn.commit()
