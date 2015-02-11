
import re
import os
import cPickle

status_re = re.compile("^HTTP/[0-9]\.[0-9] ([0-9]+)")
clen_re = re.compile("^Content-Length: ([0-9]+)")
ctype_re = re.compile("^Content-Type: (.+)$")

# walk through list
noResponses = {}
responses = {}

fh = file("results/mapping-urls-live-2014.pkl")
data = fh.read()
fh.close()
urls = cPickle.loads(data)

for u in range(len(urls)):
	url = urls[u]
	url = url.strip()

	fn = "%s.hdrs" % u
	fn = "data/live/headers/%s" % fn

	if os.path.exists(fn):
		fh = file(fn)
		data = fh.read()
		fh.close()
		lines = data.split('\n')

		statuses = []

		for l in lines:
			m = status_re.match(l)
			if m:
				status = int(m.groups()[0])
				statuses.append(status)
				continue
			m = clen_re.match(l)
			if m:
				clen = int(m.groups()[0])
				continue
			m = ctype_re.match(l)
			if m:
				ctype = m.groups()[0]

		responses[url] = {'n':u, 'status': statuses, 'clen':clen, 'ctype':ctype}
		print "%s\t%s\t%s\t%s\t%s" % (u, url, statuses, clen, ctype)
	else:
		# no response, flag it
		noResponses[url] = u


outinfo = {'responses': responses, 'noResponses': noResponses}
outstr = cPickle.dumps(outinfo)
fh = file('results/urls-live-responses.pkl', 'w')
fh.write(outstr)
fh.close()
