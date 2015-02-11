open BLACK, "<$ARGV[0]" or die;
while($line = <BLACK>) {
	chomp $line;
	$blacks{$line} = 1;
}
close BLACK;

open LINKS, "<$ARGV[1]" or die;
while($line = <LINKS>) {
	$blackLink = 0;
	foreach $b(keys %blacks) {
		if($line =~ /$b/) {
			$blackLink = 1;
			last;
		}
	}
	if($blackLink == 0) {print $line;}
}
close LINKS;
