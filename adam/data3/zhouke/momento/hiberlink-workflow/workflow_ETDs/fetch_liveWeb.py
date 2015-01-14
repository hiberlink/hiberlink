import commands
from threading import Thread, active_count
import time
import os
import cPickle

NUM_THREADS=25
SLEEPTIME=1

# Trash representations as not using them

baseDir = "data/live"
curlcmd = "curl -s -L --connect-timeout 10 -c %s/cookies/%s.cks -D %s/headers/%s.hdrs \"%s\" > /dev/null"

fh = file('results/urls-2014.pkl')
data = fh.read()
fh.close()
info = cPickle.loads(data)
urls = info.keys();
urls.sort()

mapping = {}

class FetchThread(Thread):
    def run(self):
        i = self.identifier
        commands.getoutput(curlcmd % (baseDir, i, baseDir, i, self.url))

ix = 0
while urls:
    url = urls.pop(0)
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
fh = file('results/mapping-urls-live-2014.pkl', 'w')
fh.write(outstr)
fh.close()
