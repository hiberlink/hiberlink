open DAT, "<$ARGV[0]" or die;

open ALLDOC, "<$ARGV[1]" or die;

while($line = <DAT>) {
	if($line =~ /(.*?)\t.*?\t(.*?)\t(.*?)\t(.*?)\t/) {
		$docid = $1; $sub = $2; $year = $3; $rot = $4;
		$infos{$docid} = $sub."\t".$year;
		$countLinks{$docid}++;
		if(!exists $countRotLinks{$docid}) {$countRotLinks{$docid} = 0;}
		if($rot == 0) {$countRotLinks{$docid}++;}
		
	}
}
close DAT;

while($line = <ALLDOC>) {
	if($line =~ /(.*?)\t(.*?)\t(.*?)\t/) {
		$docid = $1; $sub = $2; $year = $3;
		next if(exists $infos{$docid});
		$infos{$docid} = $sub."\t".$year;
		$countLinks{$docid} = 0;
		$countRotLinks{$docid} = 0;
	}
}


foreach $d(sort keys %infos) {
	print "$d\t$infos{$d}\t$countLinks{$d}\t$countRotLinks{$d}\n";
}

