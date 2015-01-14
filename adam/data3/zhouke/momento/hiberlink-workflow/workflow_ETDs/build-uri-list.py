import cPickle

fh = file('results/urls-2014.pkl')
data = fh.read();
fh.close()

info = cPickle.loads(data)
urls = info.keys()
urls.sort()

fh = file('results/url-list.txt', 'w')
for u in urls:
    fh.write(u)
    fh.write('\n')
fh.close()

