perl getMeta-xml-file-list.pl ../abs/ETDs.abs ETDs-xml-file-list >ETDs-xml-docwithAllMeta-month.txt

perl -lne 'm|.*?\t.*?\t.*?\tphd|&&print $_' ETDs-xml-docwithAllMeta-month.txt >ETDs-xml-phd-docwithAllMeta-month.txt

perl getMeta.pl ../abs/ETDs.abs links-filter-SpoonLib-fix2-ETDs-xml-file-list.txt >links-LTG-ETDs-all-withAllMeta-month.txt


perl filterBlackHost.pl pmc-hosts-blacklist.txt links-LTG-ETDs-all-withAllMeta-month.txt >links-LTG-ETDs-all-blackfiltered-withAllMeta-month.txt

perl -lne 'm|.*?\t.*?\t.*?\t.*?\tphd|&&print $_' links-LTG-ETDs-all-blackfiltered-withAllMeta-month.txt >links-LTG-ETDs-phd-blackfiltered-withAllMeta-month.txt

perl getLinkStatus.pl>ETDs-links-phd-unique-month.status

perl preparePeterDataset-withMonthDiff.pl  ETDs-links-phd-unique-month.status ETDs-xml-phd-docwithAllMeta-month.txt >Peters-month.dataset 

perl calcStats.pl ETDs-links-phd-unique-month.status

