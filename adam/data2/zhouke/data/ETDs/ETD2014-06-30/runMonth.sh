perl getMeta-xml-file-list.pl ../abs/ETDs.abs ETDs-xml-file-list |sort |uniq >ETDs-xml-docwithAllMeta-month.txt

perl -lne 'm|.*?\t.*?\t.*?\tphd|&&print $_' ETDs-xml-docwithAllMeta-month.txt >ETDs-xml-phd-docwithAllMeta-month.txt

perl getMeta.pl ../abs/ETDs.abs links-filter-SpoonLib-fix2-ETDs-xml-file-list.txt |sort | uniq >links-LTG-ETDs-all-withAllMeta-month.txt

perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-withAllMeta-month.txt > links-LTG-ETDs-phd-withAllMeta-month.txt

perl filterBlackHost.pl pmc-hosts-blacklist.txt links-LTG-ETDs-all-withAllMeta-month.txt >links-LTG-ETDs-all-blackfiltered-withAllMeta-month.txt

perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-blackfiltered-withAllMeta-month.txt >links-LTG-ETDs-phd-blackfiltered-withAllMeta-month.txt

# links to publisher
# links to wider web
wc -l links-LTG-ETDs-phd-blackfiltered-withAllMeta-month.txt
wc -l links-LTG-ETDs-phd-withAllMeta-month.txt




# stats about num of docs, links, publisher links

wc -l ETDs-xml-phd-docwithAllMeta-month.txt
wc -l links-LTG-ETDs-phd-withAllMeta-month.txt
wc -l links-LTG-ETDs-phd-blackfiltered-withAllMeta-month.txt

# stats about # of docs per year
perl -lne 'm|.*?\t.*?\t(.*?)-.*?\t(.*)|&&$count{$1}++; END {foreach $k(sort keys %count) {print "$k\t$count{$k}"}}' ETDs-xml-phd-docwithAllMeta-month.txt 
# stats about # of docs per subjects
perl -lne 'm|.*?\t(.*?)\t(.*?)\t(.*)|&&$count{$1}++; END {foreach $k(sort {$count{$b} <=> $count{$a}} keys %count) {print "$k\t$count{$k}"}}' ETDs-xml-phd-docwithAllMeta-month.txt |head -n 20



# stats about fraction of docs with links
perl -lne 'm|(.*?)\t.*?\t(.*?)\t(.*?)-.*?\t|&&$count{$1}++; $sub{$1}=$2; $year{$1}=$3; END {foreach $k(sort keys %count) {print "$k\t$count{$k}\t$sub{$k}\t$year{$k}\tdummy"}}' links-LTG-ETDs-phd-blackfiltered-withAllMeta-month.txt  >links-LTG-ETDs-phd-blackfiltered-month-freq.txt
wc -l links-LTG-ETDs-phd-blackfiltered-month-freq.txt
wc -l ETDs-xml-phd-docwithAllMeta-month.txt



# stats on time-aware analysis for frac (num) of docs with links
perl -lne 'm|.*?\t.*?\t.*?\t(.*?)\t|&&$count{$1}++; END {foreach $k(sort keys %count) {print "$k\t$count{$k}"}}' links-LTG-ETDs-phd-blackfiltered-month-freq.txt
# stats on subject-aware analysis for frac (num) of docs with links
perl -lne 'm|.*?\t.*?\t(.*?)\t.*|&&$count{$1}++; END {foreach $k(sort {$count{$b} <=> $count{$a}} keys %count) {print "$k\t$count{$k}"}}' links-LTG-ETDs-phd-blackfiltered-month-freq.txt |head -n 20



perl getLinkStatus.pl date>ETDs-links-phd-unique-month.status
perl getLinkStatus.pl year >ETDs-links-phd-unique-month.yearlyStatus

perl preparePeterDataset-withMonthDiff.pl  ETDs-links-phd-unique-month.status ETDs-xml-phd-docwithAllMeta-month.txt >Peters-month.dataset 

perl calcStats.pl ETDs-links-phd-unique-month.yearlyStatus
