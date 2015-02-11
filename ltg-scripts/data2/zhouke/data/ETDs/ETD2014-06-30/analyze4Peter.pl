open DAT, "<$ARGV[0]" or die;

$yearInterest = 2005;


while($line = <DAT>) {
	if($line =~ /.*?\t(.*?)\t(.*?)\t(.*?)\t/) {
		$sub = $1; $year = $2; $quant = $3;
		if($quant == 0) {$statsNum{$sub}->{$year}++;}
		else {$statsNum{$sub}->{$year}++; $statsLinks{$sub}->{$year}++;}
	}
}
close DAT;

foreach $sub(sort {$statsNum{$b}->{$yearInterest}+$statsNum{$b}->{$yearInterest+1}<=> $statsNum{$a}->{$yearInterest}+$statsNum{$a}->{$yearInterest+1}} keys %statsNum) {
	$s = 0;
	if(exists $statsNum{$sub}->{$yearInterest}) {
		$s = $statsLinks{$sub}->{$yearInterest}/$statsNum{$sub}->{$yearInterest};
	}
	$s2 = 0;
	if(exists $statsNum{$sub}->{$yearInterest+1}) {
		$s2 = $statsLinks{$sub}->{$yearInterest+1}/$statsNum{$sub}->{$yearInterest+1};
	}
	print "$sub\t$s\t$s2\t$statsNum{$sub}->{$yearInterest}\t$statsNum{$sub}->{$yearInterest+1}\n";
}
