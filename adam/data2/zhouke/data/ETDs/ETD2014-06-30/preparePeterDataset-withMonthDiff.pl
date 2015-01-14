use Date::Calc qw(Delta_Days);



open DAT, "<$ARGV[0]" or die;

open ALLDOC, "<$ARGV[1]" or die;

while($line = <DAT>) {
	if($line =~ /(.*?)\t.*?\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t/) {
		$docid = $1; $sub = $2; $year = $3; $rot = $4; $archive = $5; $tRot = $6;
	#	if($docid =~ /(.*?)-(.*?)-/) {$docid = $1."-".$2;}


		@day = split /-/, $year;
		if($day[1] eq "00") {$day[1] = "01";}
		if($day[2] eq "00") {$day[2] = "01";}
#		push @day, 1;
		@probe = (2014, 1, 1);
		$days = Delta_Days(@day, @probe);
		$lag = int ($days/29.67);

		$infos{$docid} = $sub."\t".$day[0]."\t".$days."\t".$lag;
		$countLinks{$docid}++;
		if(!exists $countRotLinks{$docid}) {$countRotLinks{$docid} = 0;}
		if($rot == 0) {$countRotLinks{$docid}++;}

		if(!exists $countArchiveRotLinks{$docid}) {$countArchiveRotLinks{$docid} = 0;}
                if($archive == 0) {$countArchiveRotLinks{$docid}++;}

                if(!exists $countTotalRotLinks{$docid}) {$countTotalRotLinks{$docid} = 0;}
                if($tRot == 0) {$countTotalRotLinks{$docid}++;}

		
	}
}
close DAT;

while($line = <ALLDOC>) {
	if($line =~ /(.*?)\t(.*?)\t(.*?)\t/) {
		$docid = $1; $sub = $2; $year = $3;
	#	if($docid =~ /(.*?)-(.*?)-/) {$docid = $1."-".$2;}

		undef $lag;
                @day = split /-/, $year;
		if($day[1] eq "00") {$day[1] = "01";}
                if($day[2] eq "00") {$day[2] = "01";}
#                push @day, 1;
                @probe = (2014, 1, 1);
	#	print "$docid\t$year\n";
                $days = Delta_Days(@day, @probe);
                $lag = int ($days/29.67);

		next if(exists $infos{$docid});
		$infos{$docid} = $sub."\t".$day[0]."\t".$days."\t".$lag;
		$countLinks{$docid} = 0;
		$countRotLinks{$docid} = 0;
		$countArchiveRotLinks{$docid} = 0;
		$countTotalRotLinks{$docid} = 0;
	}
}


foreach $d(sort keys %infos) {
	undef $institution;
	if($d =~ /^(.*?)etds/) {$institution = $1;}

	$liveLink = $countLinks{$d}-$countRotLinks{$d};
	$archiveLink = $countLinks{$d}-$countArchiveRotLinks{$d};
#	print "$institution\t$d\t$infos{$d}\t$countLinks{$d}\t$countRotLinks{$d}\t$countArchiveRotLinks{$d}\t$countTotalRotLinks{$d}\n";
#
	print "$institution\t$d\t$infos{$d}\t$countLinks{$d}\t$liveLink\t$archiveLink\t$countTotalRotLinks{$d}\n";
}

