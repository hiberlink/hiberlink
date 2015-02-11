
import re
import os
import cPickle
import commands

fh = file("results/urls-live-responses.pkl")
data = fh.read()
fh.close()
urls = cPickle.loads(data)

fh = file('results/mapping-urls-live-2014.pkl')
data = fh.read()
fh.close()
numap = cPickle.loads(data)
# mapping is number:url, need to invert
(k, v) = numap.items()
mapping = dict(zip(v,k))

baseDir = "data/live"
curlcmd = "curl -s -L --connect-timeout 30 -c %s/cookies/%s.cks -D %s/headers/%s.hdrs \"%s\" > /dev/null"

for url,resp in urls.iteritems():
	try:
		final = resp['status'][-1]
		if final > 300:
			error = 1
		else:
			error = 0
	except:
		# no status at all
		error = 1

	if error:
		# retry
		idx = mapping[url]
		print "[%s]: %s" % (idx, url)
		commands.getoutput(curlcmd % (baseDir, i, baseDir, i, url))
