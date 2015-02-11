./runToXML.sh arxiv4-pdf-file-list-9701-0703 xml9701-0703

./runToLinks.sh 

perl getlinks07to12.pl ../links-LTG-arxiv4-all.txt >links-LTG-prototype-arxiv4-0704-1212.txt

perl -lne 'm|^(\d\d\d\d)|&&$count{$1}++; END {foreach $k(sort keys %count) {print "$k\t$count{$k}"}}' links-LTG-prototype-arxiv4-0704-1212.txt 



cat links-LTG-prototype-arxiv4-0704-1212.txt links-LTG-prototype-arxiv4-0704-1212.txt > links-LTG-prototype-arxiv4-9701-1212.txt


perl getSummary_arxiv_97to12_20140328.pl /disk/data1/backup/arxiv/zhouke/data/abstract/all_abstract_ftp.txt links-LTG-prototype-arxiv4-9701-1212.txt summaries links-LTG-prototype-arxiv4-0704-1212.duplink >links-LTG-prototype-arxiv4-0704-1212.meta

tar zcvf arxiv-LTG-20140329.tar.gz summaries
