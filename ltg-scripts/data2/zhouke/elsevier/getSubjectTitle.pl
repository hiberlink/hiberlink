opendir XMLS, "$ARGV[0]" or die "can't open dir";
foreach $f(readdir XMLS) {
	next if $f eq "." or $f eq "..";
	open FILE, "<$ARGV[0]/$f" or die;
	while($line = <FILE>) {
		if($line =~ /<title>(.*?)<\/title>/) {$title = $1;}
		if($line =~ /<subject>(.*?)<\/subject>/) {$sub = $1;}
	}
	@t = split / /, $title;
	@s = split / /, $sub;
	if(exists $subs{$sub}) {$subs{$sub} = 1;}
	else {
		if(scalar(@s) <= 4 and scalar(@s) <= 20) {
			if ($sub !~ /[#|$|&|;|\/|:]/i and $title !~ /[#|$|&|;|\/|:]/) {
				if($sub =~ /journal/i or $sub =~ /research/i) {;}
				else {print "$sub\t$title\n";}
			}
		}
	}
	close FILE; 
}
