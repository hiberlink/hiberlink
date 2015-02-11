import commands
from threading import Thread, active_count
import time
import os
import cPickle

NUM_THREADS=2
SLEEPTIME=1

# ONLY headers for mementos, not full content
# To change, use equivalent command from fetch_live.py
baseDir = "data/mementos"
#curlcmd = "curl -H \"Accept-Datetime: 2012-12-12 00:00:00 GMT\" --connect-timeout 30 -I -L \"%s\" > %s/headers/%s.hdrs"
curlcmd = "curl --connect-timeout 30 -I -L \"%s\" > %s/headers/%s.hdrs"

fh = file('results/urls-2014-memento.pkl')
data = fh.read()
fh.close()
info = cPickle.loads(data)
urls = info.keys();
urls.sort()


mapping = {}

class FetchThread(Thread):
    def run(self):
        i = self.identifier
        commands.getoutput(curlcmd % (self.url, baseDir, i))
        print self.url, i


ix = 0
while urls:
    (url) = urls.pop(0)
    if os.path.exists('%s/headers/%s.hdrs' % (baseDir, ix)):
        ix += 1
        continue

    while active_count() >= NUM_THREADS:
        time.sleep(SLEEPTIME)

    t = FetchThread()
    t.identifier = ix
    t.url = url
    mapping[ix] = url
    ix += 1
    t.start()

outstr = cPickle.dumps(mapping)
fh = file('results/mapping-urls-mementos-2014.pkl', 'w')
fh.write(outstr)
fh.close()
