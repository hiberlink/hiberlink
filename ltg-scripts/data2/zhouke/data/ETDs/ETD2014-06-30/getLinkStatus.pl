use Date::Calc qw(Delta_Days);

# option: 
# "year"
# "date"

$option = $ARGV[0];


# assuming this file only contains the phd URL we want
open ARCHIVEUNIQ, "<memento-links-LTG-ETDs-phd-blackfiltered.status" or die;

while($line = <ARCHIVEUNIQ>) {
	if($line =~ /.*?\t(.*?)\t(.*)/) {
		$url = $1; $avail = $2; chomp $avail;
		if($avail == 1) {$archive = 1;}
		elsif($avail == 0) {$archive = 0;}
		else {print "ERROR\n"; exit;}
		$urlArchive{$url} = $archive;
	}
}
close ARCHIVEUNIQ;

open LIVEUNIQ, "<URLavail-links-ETDs-blackfiltered.unique" or die;
while($line = <LIVEUNIQ>) {
	if($line =~ /.*?\t(.*?)\t(.*)/) {
		$url = $1; $avail = $2; chomp $avail;
		$avail =~ s/\r//g;
		next if(exists $lives{$url});
		$lives{$url} = $avail;
		next if(!exists $urlArchive{$url});
		if($avail =~ /[a-z]+/) {$live = 0;}
		elsif($avail =~ /\d+/) {
			if($avail < 400) {
				$live = 1;
			}
			else {
				$live = 0;
			}
		}
		else {print "ERROR:ARCHIVE: $avail\n"; exit;}
		#print "$url\t$live\t$urlArchive{$url}\n";
		$urlLive{$url} = $live;
		$avail = $urlLive{$url} + $urlArchive{$url}; if($avail >=1) {$avail = 1;} else {$avail = 0;}
		$urlAvail{$url} = $avail;
	}
}

close LIVEUNIQ;


open LINK, "<links-LTG-ETDs-phd-blackfiltered-withAllMeta-month.txt" or die;
while($line = <LINK>) {
	if($line =~ /(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*)/) {
		$docid = $1; $url = $2; $sub = $3; $year = $4; $type = $5; chomp $type;
		$live = $urlLive{$url};
		$archive = $urlArchive{$url};
		$avail = $urlAvail{$url};

                undef $lag;
                @day = split /-/, $year;
                if($day[1] eq "00") {$day[1] = "01";}
		if($day[2] eq "00") {$day[2] = "01";}
#                push @day, 1;
                @probe = (2014, 1, 1);
        	$days = Delta_Days(@day, @probe);
        	$lag = int ($days/29.67);

		if($option eq "date") {;}
		else {$year = $day[0];}


		print "$docid\t$url\t$sub\t$year\t$live\t$archive\t$avail\t$type\t$lag\tdummy2\n";
	}
}
close LINK;


