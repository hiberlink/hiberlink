import cPickle

fh = file('results/urls-2014-memento.pkl')
data = fh.read();
fh.close()

info = cPickle.loads(data)
urls = info.keys()
urls.sort()

fh = file('results/urls-2014-memento.txt', 'w')
for u in urls:
    fh.write(u)
    fh.write('\n')
fh.close()

