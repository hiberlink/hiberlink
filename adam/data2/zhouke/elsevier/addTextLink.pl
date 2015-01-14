# ARGV[0]: text link file, format: id: link
# ARGV[1]: summary file folder
# ARGV[2]: new summary file folder
#
open TEXTLINK, "<$ARGV[0]" or die "argv0";
while($line = <TEXTLINK>) {
	if($line =~ /(.*?): (.*)/) {
		$id = $1; $link = $2; chomp $link;
		$link =~ s/&/&amp;/g; $link =~ s/</&lt;/g;
		push @{$txtlinks{$id}}, $link;
	}
}
close TEXTLINK;


opendir SUMMARY, "$ARGV[1]" or die "argv1";
foreach $f(readdir SUMMARY) {
	next if ($f eq "." or $f eq "..");
	open SOURCE, "<$ARGV[1]/$f" or die "$f";
	open OUT, ">$ARGV[2]/$f" or die "o $f";
	while($line = <SOURCE>) {
		if($line =~ /<links>/) {
			print OUT $line;
			# store all extracted links
			undef @extLinks;
			while($line = <SOURCE>) {
				if($line =~ /<link.*?>(.*?)<\/link>/) {
					push @extLinks, $1;
					print OUT $line;
				}
				if($line =~ /<\/links>/) {
					last;
				}
			}
			# add all text links (if not duplicate)
			if($f =~ /(.*?)\.xml/) {$pubid = $1;}
			foreach $txtl(@{$txtlinks{$pubid}}) {
				$dup = 0;
				foreach $extl(@extLinks) {
					# dup found
					if($txtl eq $extl) {
						$dup = 1; last;	
					}
				}
				if($dup == 0) {print OUT "\t\t<link>$txtl</link>\n";}
			}
		}
		print OUT $line;
	}
	close SOURCE;
	close OUT;
}
closedir SUMMARY;


