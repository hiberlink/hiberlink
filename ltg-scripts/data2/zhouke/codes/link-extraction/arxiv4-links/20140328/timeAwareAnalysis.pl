open LINK, "<$ARGV[0]" or die;
while($line = <LINK>) {
	if($line =~ /^(\d\d)/) {
		$count{$1}++;
	}
	elsif($line =~ /\|(\d\d)/) {
		$count{$1}++;
	}
}
close LINK;

foreach $k(sort keys %count) {
	print "$k\t$count{$k}\n";
}
