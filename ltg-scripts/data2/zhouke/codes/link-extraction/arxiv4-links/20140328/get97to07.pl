open FILE, "<$ARGV[0]" or die "can't open pdf-file-list";
while($line = <FILE>) {
	if($line =~ /\/pdf\/(\d\d)(\d\d)/) {
		$year = $1; $month = $2;
                if($year gt "96") {
			print $line;
			next;
		}
		else {
			if($year lt "07") {
				print $line;
                                next;
			}
			elsif($year eq "07") {
				if($month lt "04") {print $line; next;}
			}
                        else {;}
                }
	}
}
close FILE;
