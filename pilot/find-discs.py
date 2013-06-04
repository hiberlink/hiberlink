
import sqlite3
import sys
import urlparse

blacklist = ['localhost','www.slac.stanford.edu', 'www-spires.slac.stanford.edu', 'www.arxiv.org', 'arxiv.org', 'xxx.lanl.gov', 'dx.doi.org', 'google-analytics.com']

urlblacklist = []

def sanitize_url(url):
    url = url.strip()

    # turn crazy ~ into regular ~
    url = url.replace('\xe2\x88\xbc', '~')
    
    #sanity check the URL
    if not url.lower().startswith('http://') and not url.lower().startswith('https://'):
        url = 'http://' + url

    # Maybe append trailing slash
    if url.count('/') == 2:
        url = url + '/'
    
    try:
        bits = urlparse.urlparse(url)
    except:
        print 'failed to parse: ' + url
        return ''
    # check if known TLD
    if not bits.netloc:
        print 'no host: ' + url
        return ''
    else:
        host = bits.netloc
        if host.find(':') > -1:
            (host,port) = host.split(':', 1)
            if not port.isdigit():
                print 'broken port: ' + url
                return ''
        host = host.lower()
            
    if url in urlblacklist:
        print 'urlblacklist: ' + url
    if host in blacklist:
        print 'blacklist: ' + url
        return ''
    nb = host.split('.')
    if not nb[-1] in tldlist and not nb[-1].isdigit():
        print 'no tld: ' + url
        return ''
    return url


    
con = sqlite3.connect('./url-tms.sqlite')
c = con.cursor()

# for each uri in timemaps, find discs

r = c.execute('select t.url, t.exist, t.archive, p.disc from timemaps t, papertimes p where t.url = p.url')  

dischash = {}
x = 0
while 1:
    x += 1
    if not x % 1000:
        print x 
    try:
        (url, exist, archive, disc) = r.fetchone()
    except:
        break
    try:
        dischash[disc].append((url, exist, archive))
    except:
        dischash[disc] = [(url, exist, archive)]

ndiscs = len(dischash)
ttl = sum([len(x) for x in dischash.values()])
discs = dischash.items()
discs.sort(key=lambda x:len(x[1]), reverse=True)

fh = file('exist-archive-perdisc.csv', 'w')
fh.write('"Discipline","Exists","Archived","Total"\n')

for d in discs:
    exst = sum([x[1] for x in d[1]])
    arch = sum([x[2] for x in d[1]])
    fh.write('"%s",%s,%s,%s\n' % (d[0], exst, arch, len(d[1])))
fh.close()

con.commit()
con.close()
