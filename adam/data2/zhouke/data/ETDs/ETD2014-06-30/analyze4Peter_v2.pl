open DAT, "<$ARGV[0]" or die;

$yearInterest = 2006;


while($line = <DAT>) {
	if($line =~ /.*?\t(.*?)\t(.*?)\t(.*?)\t/) {
		$sub = $1; $year = $2; $quant = $3;
		if($quant == 0) {$statsNum{$sub}->{$year}++;}
		else {$statsNum{$sub}->{$year}++; $statsLinks{$sub}->{$year}++;}
		$years{$year} = 1;
	}
}
close DAT;

print "#SUBJECT";
foreach $y(sort keys %years) {
	print "\te-theses($y)\twith-links($y)";
}
print "\n";
foreach $sub(sort {$statsNum{$b}->{$yearInterest}+$statsNum{$b}->{$yearInterest+1}<=> $statsNum{$a}->{$yearInterest}+$statsNum{$a}->{$yearInterest+1}} keys %statsNum) {
	print "$sub";
	foreach $y(sort keys %years) {
        	$s = 0;
        	if(exists $statsNum{$sub}->{$y}) {
                	$s = $statsLinks{$sub}->{$y}/$statsNum{$sub}->{$y};
        	}
		else {$statsNum{$sub}->{$y} = 0;}

		print "\t$statsNum{$sub}->{$y}\t$s";		
	}
	print "\n";
}

