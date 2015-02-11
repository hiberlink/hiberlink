
from lxml import etree
import cPickle
import re, sys, os
from dateutil import parser as dateparser
import hashlib

hostfinder = re.compile('^http(s)?://([^/:]+)(:[0-9]+)?(/|$)')
wwwkill = re.compile('^www([0-9]+)?\.')
sane = re.compile('^http(s)?://([a-zA-Z0-9])+')
baddoi = re.compile('^http://10.[0-9]{4}/')
hostfinder = re.compile('^http(s)?://([^/:]+)(:[0-9]+)?(/|$)')
numericre = re.compile('([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)')

basedir = "/disk/data2/zhouke/data/ETDs/ETD2014-06-12/summaries"

# Load list of blacklist hosts
fh = file('resources/pmc-hosts-blacklist.txt')
hostbl = fh.readlines()
fh.close()
hostblacklist = dict([(x.strip(),1) for x in hostbl])

fh = file("resources/tlds-alpha-by-domain.txt")
tlds = fh.readlines()
fh.close()
tlds = tlds[1:]
tldhash = dict([(x.lower()[:-1], 1) for x in tlds])

fh = file('resources/xref-hashed-domains.txt')
xrefhash = fh.read()
fh.close()

urlblacklisturls = [
	'http://www.elsevier.com/wps/find/authorsview.authors/supplementalterms1.0',
	'http://www.frontiersin.org/licenseagreement',
	'http://journals.iucr.org/services/termsofuse.html',
	'http://wileyonlinelibrary.com/onlineopen#onlineopen_terms',
	'http://wileyonlinelibrary.com/onlineopen#onlineopen-terms',
	'http://wileyonlinelibrary.com/onlineopen##onlineopen_terms',
	'http://www.wileyonlinelibrary.com/onlineopen#onlineopen_terms',
	'http://wileyonlinelibrary.com/onlineopen#/onlineopen_terms',
	'http://wileyonlinelibrary.com/onlineopen#onlineopen_termsconflict',
	'http://wileyonlinelibrary.com/onlineopen',
	'http://wileyonlinelibrary.com/onlineopen#onlinepen_terms',
	'http://wileyonlinelibrary.com/onlineopen~onlineopen_terms',
	'http://wileyonlinelibrary.com/onlineopenonlineopen_terms',
	'http://wileyonlinelibrary.com/onlineopen#']
urlblacklist = dict([(x,1) for x in urlblacklisturls])


all_urls = {}
journals = {}
filtered = {'doi':[], 'shouldBeDoi':[], 'syntax':[], 'nonweb': [], 'memento':[], 'metadata':[]}

nonWebHosts = [
	'example.org',
	'example.com',
	'example.net',
	'example.edu',
	'localhost',
	'127.0.0.1'
]

nonWebBlacklist = dict([(x,1) for x in nonWebHosts])

files =	os.listdir(basedir)
urlCounts = {'okay':0, 'doi':0, 'shouldBeDoi':0, 'syntax':0, 'nonweb': 0, 'memento':0, 'metadata':0, 'time':0}

for fn in files:
	try:
		fh = file(os.path.join(basedir, fn))
	except:
		print " --- Could not open: %s/%s" % (basedir,fn)
		continue
	data = fh.read()
	fh.close()
	data = data.replace('encoding="ISO-646"', '')
	dom = etree.XML(data)

	links = dom.xpath('/document/links/link')
	mylinks = []
	for l in links:
		try:
			context = l.attrib.get('context', '')
			href = l.text

			lto = l.attrib.get('to', '')
			if lto in ['graphic', 'media']:
				continue
			if lto == 'license':
				urlCounts['metadata'] += 1
				filtered['metadata'].append(href)
				continue

			if not href:
				urlCounts['syntax'] += 1
				filtered['syntax'].append(href)
				continue

			href = href.strip().replace(' ', '')
			href = href.replace('\n', '')
			href = href.replace('\r', '')

			if (href.startswith("http://") or href.startswith("https://")) and href.find('.') > -1 and sane.match(href) and not baddoi.match(href):
				# http/s, has at least one '.' and isn't DOI thing like http://10.1016/foo 

				atidx = href.find('@')
				slidx = href[9:].find('/')
				if atidx > -1 and (slidx == -1 or atidx < slidx+8):
					# Passworded URL?!
					urlCounts['syntax'] += 1
					filtered['syntax'].append(href)
					continue

				try:
					str(href)
				except:
					# Strange characters in URL
					urlCounts['syntax'] += 1
					filtered['syntax'].append(href)
					continue

				# Sanity check hostname
				hm = hostfinder.match(href)
				if hm:
					host = hm.groups()[1]
					bits = host.split('.')
					if not bits[-1].isdigit() and not tldhash.has_key(bits[-1].lower()):
						# last is only numbers, or not a TLD
						urlCounts['syntax'] += 1
						filtered['syntax'].append(href)
						continue

					# Filter private addresses
					nmm = numericre.match(host)
					if nmm:
						numbits = nmm.groups()
						if numbits[0] in ['10', '255']:
							urlCounts['nonweb'] += 1
							filtered['nonweb'].append(href)
							continue
						elif numbits[0] == '192' and numbits[1] == '168':
							urlCounts['nonweb'] += 1
							filtered['nonweb'].append(href)
							continue
						elif numbits[0] == '172':
							nbt = int(numbits[1])
							if nbt >=16 or nbt <= 31:
								filtered['nonweb'].append(href)
								urlCounts['nonweb'] += 1
								continue
					elif bits[-1].isdigit():
						# http://1012.9876
						urlCounts['syntax'] += 1
						filtered['syntax'].append(href)
						continue

					lhost = host.lower()
					lwhost = wwwkill.sub('', lhost)						

					if nonWebBlacklist.has_key(lhost):
						filtered['nonweb'].append(href)
						urlCounts['nonweb'] += 1
						continue

					# Minimally Canonicalize: lowercase host, add / path if not present
					href = href.replace(host, lhost)
					if href.endswith(lhost):
						href = href + '/'

					if lhost == 'dx.doi.org':
						filtered['doi'].append(href)
						urlCounts['doi'] += 1
						continue

					m = hashlib.sha256()
					m.update(lhost)
					hd = m.hexdigest()
					if xrefhash.find(hd) > -1:
						# DOI from hash
						filtered['shouldBeDoi'].append(href)
						urlCounts['shouldBeDoi'] += 1
						continue

					if hostblacklist.has_key(lhost):
						# in hostname blacklist
						filtered['shouldBeDoi'].append(href)
						urlCounts['shouldBeDoi'] += 1
						continue
					if hostblacklist.has_key(lwhost):
						# in hostname blacklist without www
						filtered['shouldBeDoi'].append(href)
						urlCounts['shouldBeDoi'] += 1
						continue

					if urlblacklist.has_key(href.lower()):
						# in url blacklist
						filtered['metadata'].append(href)
						urlCounts['metadata'] += 1
						continue

					if lhost.find('ezproxy.') > -1:
						filtered['shouldBeDoi'].append(href)
						urlCounts['shouldBeDoi'] += 1
						continue						

					iswebCite = href.find('webcitation.org') > -1
					isArchiveOrg = href.find('web.archive.org') > -1
					isOldid = href.find('oldid=') > -1 and lhost.find('wikipedia.org') > -1
					if iswebCite or isArchiveOrg or isOldid:
						filtered['memento'].append(href)
						urlCounts['memento'] += 1
						continue

				else:
					filtered['syntax'].append(href)
					urlCounts['syntax'] += 1
					continue

				href = 'http://selma:8080/aggr/timegate/' + href
				mylinks.append((href, l.attrib.get('context', '')))
			else:
				# Failed http/s test
				urlCounts['syntax'] += 1
				continue
		except:
			raise

	if mylinks:
		date = dom.xpath('/document/dates/date[@type="first submission"]')		
		if not date:
			date = dom.xpath('/document/dates/date')
			if not date:
				# No dates!?
				urlCounts['time'] += 1
				continue
		date = date[0]
			
		dtxt = date.text
		if dtxt[0] == "1":
			dtxt = dtxt.replace(" GMT", '')

		try:
			pdate = dateparser.parse(dtxt)
		except:
			print "broken date: %s" % date.text

			urlCounts['time'] += 1
			continue

		if pdate.year > 1995 and pdate.year < 2013:		
			for l in mylinks:
				try:
					all_urls[l[0]].append((fn, l[1], pdate))
				except:
					all_urls[l[0]] = [(fn, l[1], pdate)]
				urlCounts['okay'] += 1
		else:
			urlCounts['time'] += 1




fh = file('results/urls-2014-memento.pkl', 'w')
data = cPickle.dumps(all_urls)
fh.write(data)
fh.close()

fh = file('results/filtered-2014-memento.pkl', 'w')
data = cPickle.dumps(filtered)
fh.write(data)
fh.close()

fh = file('results/journals-2014-memento.pkl', 'w')
data = cPickle.dumps(journals)
fh.write(data)
fh.close()




