open FILE, "<$ARGV[0]" or die "can't open pdf-file-list";
while($line = <FILE>) {
	if($line =~ /^(\d\d)(\d\d)/) {
		$year = $1; $month = $2;
                if($year lt "90") {
			if($year gt "07") {
				if($year lt "13") {
					print $line;
					next;
				}
			}
			elsif($year eq "07") {
				if($month gt "03") {print $line; next;}
			}
			else {;}
		}
		else {;}
	}
}
close FILE;
