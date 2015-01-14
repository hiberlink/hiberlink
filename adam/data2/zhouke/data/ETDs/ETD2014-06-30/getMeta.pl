open ABS, "<$ARGV[0]" or die;
while($line = <ABS>) {
	if($line =~ /\/pdf\/(.*?)\/data\/(.*?)\/info/) {
		$docid = $1."-".$2;
		undef $subject; undef $degree; undef $date; undef $year;
		undef $month; undef $day;		


		$line = <ABS>; 
		if($line =~ /^id:/) {$line = <ABS>;}
		$line = <ABS>; 
		if($line =~ /degree:\s+(.*)/) {
			$degree = $1; chomp $degree;
			# manual rule and checked it works fine (by printing out and view all)
			# perl getMeta-xml-file-list.pl ../abs/ETDs.abs ETDs-xml-file-list | perl -lne 'm|.*?\t.*?\t.*?\t(.*)|&&print $1' | sort | uniq
			if($degree =~ /^m/i) {$degree = "master";}
			elsif($degree =~ /^-/) {undef $degree;}
			else {$degree = "phd";}
		}
		$line = <ABS>;
		if($line =~ /dept:\s+(.*?) /) {
			$subject = $1;
			$subject =~ s/,//g;
			$subject = lc($subject);
			
		}
		$line = <ABS>; 
		if($line =~ /date: (.*?)-(.*?)-(.*)/) {
			$year = $1;
			$month = $2; 
			$day = $3; chomp $day;
			$date = $year."-".$month."-".$day;
			next if($year !~ /\d/);
			next if($subject !~ /\w/);
			next if($degree !~ /\w/);
			next if($year < 1997 or $year > 2010);

			$infos{$docid} = $subject."\t".$date."\t".$degree;
		}
		
	}
}
close ABS;

open LINK, "<$ARGV[1]" or die;
while($line = <LINK>) {
        if($line =~ /(.*?)-(.*?)-(.*?)\.pdf\.xml: (.*)/) {
                $docid = $1."-".$2;
                #$newDocid = $docid."-".$3.".pdf.xml";
		$newDocid = $docid;
                $url = $4; chomp $url;
		if(exists $infos{$docid}) { 
               		$content = $infos{$docid};
                	print "$newDocid\t$url\t$content\n";
		}
        }
}

close LINK;

