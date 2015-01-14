open MEMENTO, "<$ARGV[0]" or die;
open URLARCHIVE, "</disk/data2/zhouke/data/ETDs/ETD2014-06-30/links-LTG-ETDs-phd-blackfiltered.unique" or die;
while($line = <MEMENTO>) {
	if($line =~ /^.*?\thttp:\/\/selma:8080\/aggr\/timegate\/(.*?)\t.*?\t(.*?)\t/) {
		$url = $1; $size = $2; 
		if($size > 0) {$memento{$url} = 1;}
		else {$memento{$url} = 0;}
	}
}
close MEMENTO;

while($line = <URLARCHIVE>) {
	$url = $line; chomp $url;
	if(!exists $memento{$url}) {
		$memento{$url} = $status;
	}
}
close URLARCHIVE;

foreach $url(keys %memento) {
	print "null\t$url\t$memento{$url}\n";
}
