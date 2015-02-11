# assuming this file only contains the phd URL we want
open ARCHIVEUNIQ, "<memento-links-LTG-ETDs-phd-blackfiltered.status" or die;

while($line = <ARCHIVEUNIQ>) {
	if($line =~ /.*?\t(.*?)\t(.*)/) {
		$url = $1; $avail = $2; chomp $avail;
		if($avail == 1) {$archive = "T";}
		elsif($avail == 0) {$archive = "F";}
		else {print "ERROR\n"; exit;}
		$urlArchive{$url} = $archive;
	}
}
close ARCHIVEUNIQ;

open LIVEUNIQ, "<URLavail-links-ETDs-blackfiltered.unique" or die;
while($line = <LIVEUNIQ>) {
	if($line =~ /.*?\t(.*?)\t(.*)/) {
		$url = $1; $avail = $2; chomp $avail;
		next if(exists $urlLive{$url});
		$urlLive{$url} = $avail;
		next if(!exists $urlArchive{$url});
		if($avail =~ /[a-z]+/) {$live = "F";}
		elsif($avail =~ /\d+/) {
			if($avail < 400) {
				$live = "T";
			}
			else {
				$live = "F";
			}
		}
		else {print "ERROR:ARCHIVE\n"; exit;}
		print "$url\t$live\t$urlArchive{$url}\n";
	}
}

close LIVEUNIQ;



