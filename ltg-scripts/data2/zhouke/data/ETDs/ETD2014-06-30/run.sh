perl getMeta-xml-file-list.pl ../abs/ETDs.abs ETDs-xml-file-list >ETDs-xml-docwithAllMeta.txt

perl getMeta.pl ../abs/ETDs.abs links-filter-SpoonLib-fix2-ETDs-xml-file-list.txt >links-LTG-ETDs-all-withAllMeta.txt

perl filterBlackHost.pl pmc-hosts-blacklist.txt links-LTG-ETDs-all-withAllMeta.txt >links-LTG-ETDs-all-blackfiltered-withAllMeta.txt


# stats about master vs. phd thesis
perl -lne 'm|.*?\t.*?\t.*?\tmaster|&&print $_' ETDs-xml-docwithAllMeta.txt | wc -l
perl -lne 'm|.*?\t.*?\t.*?\tphd|&&print $_' ETDs-xml-docwithAllMeta.txt | wc -l
wc -l ETDs-xml-docwithAllMeta.txt

# get only the phd thesis for further analysis
perl -lne 'm|.*?\t.*?\t.*?\tphd|&&print $_' ETDs-xml-docwithAllMeta.txt >ETDs-xml-phd-docwithAllMeta.txt
perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-withAllMeta.txt >links-LTG-ETDs-phd-withAllMeta.txt
perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-blackfiltered-withAllMeta.txt >links-LTG-ETDs-phd-blackfiltered-withAllMeta.txt


# stats about # of docs per year
perl -lne 'm|.*?\t.*?\t(.*?)\t(.*)|&&$count{$1}++; END {foreach $k(sort keys %count) {print "$k\t$count{$k}"}}' ETDs-xml-phd-docwithAllMeta.txt >> stats.txt

# stats about # of docs per subjects
perl -lne 'm|.*?\t(.*?)\t(.*?)\t(.*)|&&$count{$1}++; END {foreach $k(sort {$count{$b} <=> $count{$a}} keys %count) {print "$k\t$count{$k}"}}' ETDs-xml-phd-docwithAllMeta.txt >> stats.txt

# stats about fraction of docs with links
perl -lne 'm|(.*?)\t.*?\t(.*?)\t(.*?)\t|&&$count{$1}++; $sub{$1}=$2; $year{$1}=$3; END {foreach $k(sort keys %count) {print "$k\t$count{$k}\t$sub{$k}\t$year{$k}\tdummy"}}' links-LTG-ETDs-phd-blackfiltered-withAllMeta.txt  >links-LTG-ETDs-phd-blackfiltered-freq.txt
wc -l links-LTG-ETDs-phd-blackfiltered-freq.txt
wc -l ETDs-xml-phd-docwithAllMeta.txt 


# stats on time-aware analysis for frac (num) of docs with links
perl -lne 'm|.*?\t.*?\t.*?\t(.*?)\t|&&$count{$1}++; END {foreach $k(sort keys %count) {print "$k\t$count{$k}"}}' links-LTG-ETDs-phd-blackfiltered-freq.txt 


# stats on subject-aware analysis for frac (num) of docs with links
perl -lne 'm|.*?\t.*?\t(.*?)\t.*|&&$count{$1}++; END {foreach $k(sort {$count{$b} <=> $count{$a}} keys %count) {print "$k\t$count{$k}"}}' links-LTG-ETDs-phd-blackfiltered-freq.txt 



# stats about total num of links
wc -l links-LTG-ETDs-phd-blackfiltered-withAllMeta.txt


# get the link status (live web and internet archive)
# liveweb -> already have: /disk/data2/zhouke/codes/probe/wget-liveweb/ETDs/URLavail-links-ETDs-blackfiltered.txt
# archive -> still need to obtain

# get unique links to proble (in archive)
perl -lne 'm|.*?\t(.*?)\t|&&print $1' links-LTG-ETDs-phd-blackfiltered-withAllMeta.txt |sort |uniq >links-LTG-ETDs-phd-blackfiltered.unique
# get archive status
cp links-LTG-ETDs-phd-blackfiltered.unique /disk/data2/zhouke/codes/probe/wget-archive/ETDs/
cd /disk/data2/zhouke/codes/probe/wget-archive/ETDs
split -l 1000 links-LTG-ETDs-phd-blackfiltered.unique links-LTG-ETDs-phd-blackfiltered_
mv links-LTG-ETDs-phd-blackfiltered_* links/
perl run.pl
#wait to finish
mv URLArchiveAvail/URLArchiveAvail-links-LTG-ETDs-phd-blackfiltered_*-* ./
cat URLArchiveAvail/URLArchiveAvail-links-LTG-ETDs-phd-blackfiltered_* >URLArchiveAvail-links-LTG-ETDs-phd-blackfiltered.unique
mv URLArchiveAvail-links-LTG-ETDs-phd-blackfiltered_*-* URLArchiveAvail/
cd /disk/data2/zhouke/data/ETDs/ETD2014-06-12/

# get final link status file (link \t live (T or F) \t archive (T or F)
# by combining /disk/data2/zhouke/codes/probe/wget-archive/ETDs/URLArchiveAvail-links-LTG-ETDs-phd-blackfiltered.unique
# and /disk/data2/zhouke/codes/probe/wget-liveweb/ETDs/URLavail-links-ETDs-blackfiltered.txt
cp /disk/data2/zhouke/codes/probe/wget-archive/ETDs/URLArchiveAvail-links-LTG-ETDs-phd-blackfiltered.unique ./
perl -lne 'm|.*?\t(.*?)\t.*?\t(.*)|&&print "null\t$1\t$2"' /disk/data2/zhouke/codes/probe/wget-liveweb/ETDs/URLavail-links-ETDs-blackfiltered.txt |sort |uniq >URLavail-links-ETDs-blackfiltered.unique
# not useful
perl getStdStatus.pl >ETDs-links-phd-unique_stats_4ltg.dat

perl getLinkStatus.pl>ETDs-links-phd-unique.status


# calc stats on link rot analysis
# also perform time and subject and general analysis
perl calcStats.pl ETDs-links-phd-unique.status 


# prepare Dataset requested by Peter on June 17 2014
perl preparePeterDataset.pl ETDs-links-phd-unique.status ETDs-xml-phd-docwithAllMeta.txt 

# analyze for Peter on 2005/2006 jump
perl analyze4Peter.pl Peters.dataset

# get all link num for Peter (by year)
perl -lne 'm|.*?\t.*?\t.*?\t(.*?)\t|&&$count{$1}++; END {foreach $k(sort keys %count) {print "$k\t$count{$k}"}}' links-LTG-ETDs-phd-blackfiltered-withAllMeta.txt >Peters.allLinks




