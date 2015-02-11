perl getMeta20140627.pl ../abs/ETDs.abs links-filter-SpoonLib-fix2-ETDs-xml-file-list.txt >links-LTG-ETDs-all-withAllMeta-day.txt


#perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-withAllMeta-day.txt >links-LTG-ETDs-phd-withAllMeta-day.txt

perl filterBlackHost.pl pmc-hosts-blacklist.txt links-LTG-ETDs-all-withAllMeta-day.txt >links-LTG-ETDs-all-blackfiltered-withAllMeta-day.txt

perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-blackfiltered-withAllMeta-day.txt >links-LTG-ETDs-phd-blackfiltered-withAllMeta-day.txt


mkdir summaries

perl getSummary4ETDs.pl links-LTG-ETDs-phd-blackfiltered-withAllMeta-day.txt summaries links-LTG-ETDs-phd-blackfiltered-withAllMeta-day.duplinks



