
import re
import os
import cPickle

status_re = re.compile("^HTTP/[0-9]\.[0-9] ([0-9]+)")
clen_re = re.compile("^Content-Length: ([0-9]+)")
ctype_re = re.compile("^Content-Type: (.+)$")
mdt_re = re.compile("^Memento-Datetime: (.*)")

# walk through list
noResponses = {}
responses = {}

fh = file("results/mapping-urls-mementos-2014.pkl")
data = fh.read()
fh.close()
urls = cPickle.loads(data)

for u in range(len(urls)):
	url = urls[u]
	url = url.strip()

	fn = "%s.hdrs" % u
	fn = "data/mementos/headers/%s" % fn
	#print fn

	if os.path.exists(fn):
		fh = file(fn)
		data = fh.read()
		fh.close()
		lines = data.split('\n')

		statuses = []
		mdt = ""
		ctype = ""
		clen = 0

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
				continue
			m = mdt_re.match(l)
			if m:
				mdt = m.groups()[0]
				continue

		responses[url] = {'n':u, 'status': statuses, 'clen':clen, 'ctype':ctype, 'mdt': mdt}
		print "%s\t%s\t%s\t%s\t%s\t%s" % (u, url, statuses, clen, ctype, mdt)
	else:
		# no response, flag it
		noResponses[url] = u

results = {'responses': responses, 'noResponses': noResponses}
outpkl = cPickle.dumps(results)
fh = file('results/urls-mementos-responses.pkl', 'w')
fh.write(outpkl)
fh.close()
