open STATUS, "<$ARGV[0]" or die;
while($line = <STATUS>) {
    if($line =~ /.*?\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t(.*?)\t/) {
        $url = $1;
        $subject = $2; $year = $3; $live = $4; $momento = $5; $avail = $6; $openaccess = $7; $pos = $8;

        $urlLevel =()= $url =~ /\//gi;
        if($urlLevel > 8) {$urlLevel = 9;}
        $urlLength = $urlLevel;
        #$urlLength = length($url);
        #        if($urlLength > 100) {$urlLength = "0-exLong";}
        #elsif($urlLength > 50) {$urlLength = "1-long";}
        #elsif($urlLength >30) {$urlLength = "2-medium";}
        #elsif($urlLength > 15) {$urlLength = "3-short";}
        #else {$urlLength = "4-exShort";}
        
        
        #        print "$live $momento $avail $openaccess\n";
        
        
        $subs{$subject}->{"count"}++;
        $subs{$subject}->{"live"} += $live;
        $subs{$subject}->{"momento"} += $momento;
        if($live == 0 and $momento == 1) {$subs{$subject}->{"archiverot"}++;}
        if($live == 0 and $momento == 0) {$subs{$subject}->{"noarchiverot"}++;}
        $subs{$subject}->{"avail"} += $avail;
        
        $opens{$openaccess}->{"count"}++;
        $opens{$openaccess}->{"live"} += $live;
        $opens{$openaccess}->{"momento"} += $momento;
        if($live == 0 and $momento == 1) {$opens{$openaccess}->{"archiverot"}++;}
        if($live == 0 and $momento == 0) {$opens{$openaccess}->{"noarchiverot"}++;}
if($live == 1 and $momento == 0) {$opens{$openaccess}->{"liveNoArchive"}++;}
if($live == 1 and $momento == 1) {$opens{$openaccess}->{"liveArchive"}++;}
        $opens{$openaccess}->{"avail"} += $avail;
        
        $years{$year}->{"count"}++;
        $years{$year}->{"live"} += $live;
        $years{$year}->{"momento"} += $momento;
        if($live == 0 and $momento == 1) {$years{$year}->{"archiverot"}++;}
        if($live == 0 and $momento == 0) {$years{$year}->{"noarchiverot"}++;}
        $years{$year}->{"avail"} += $avail;

        $urlLens{$urlLength}->{"count"}++;
        $urlLens{$urlLength}->{"live"} += $live;
        $urlLens{$urlLength}->{"momento"} += $momento;
        if($live == 0 and $momento == 1) {$urlLens{$urlLength}->{"archiverot"}++;}
        if($live == 0 and $momento == 0) {$urlLens{$urlLength}->{"noarchiverot"}++;}
        $urlLens{$urlLength}->{"avail"} += $avail;
        
        $poses{$pos}->{"count"}++;
        $poses{$pos}->{"live"} += $live;
        $poses{$pos}->{"momento"} += $momento;
        if($live == 0 and $momento == 1) {$poses{$pos}->{"archiverot"}++;}
        if($live == 0 and $momento == 0) {$poses{$pos}->{"noarchiverot"}++;}
        $poses{$pos}->{"avail"} += $avail;
        
        

    }
}
close STATUS;

foreach $s(sort keys %subs) {
    $countLiveRot = $subs{$s}->{"count"} - $subs{$s}->{"live"};
    
    $fracLiveRot = $countLiveRot / $subs{$s}->{"count"};
    $fracArchive = $subs{$s}->{"momento"} / $subs{$s}->{"count"};
    $fracArchiveRot = $subs{$s}->{"archiverot"} / $subs{$s}->{"count"};
    $fracNoArchiveRot = $subs{$s}->{"noarchiverot"} / $subs{$s}->{"count"};
    
    print "$s\t$countLiveRot\t$fracLiveRot\t$fracArchive\t$fracArchiveRot\t$fracNoArchiveRot\n";
}

print "\n";


foreach $s(sort keys %years) {
    $countLiveRot = $years{$s}->{"count"} - $years{$s}->{"live"};
    
    $fracLiveRot = $countLiveRot / $years{$s}->{"count"};
    $fracArchive = $years{$s}->{"momento"} / $years{$s}->{"count"};
    $fracArchiveRot = $years{$s}->{"archiverot"} / $years{$s}->{"count"};
    $fracNoArchiveRot = $years{$s}->{"noarchiverot"} / $years{$s}->{"count"};
    
     $countRotLink = $years{$s}->{"noarchiverot"};

    print "$s\t$countRotLink\t$fracLiveRot\t$fracArchive\t$fracArchiveRot\t$fracNoArchiveRot\n";
}

print "\n";


foreach $s(sort keys %opens) {
    $countLiveRot = $opens{$s}->{"count"} - $opens{$s}->{"live"};
    
    $fracLiveRot = $countLiveRot / $opens{$s}->{"count"};
    $fracArchive = $opens{$s}->{"momento"} / $opens{$s}->{"count"};
    $fracArchiveRot = $opens{$s}->{"archiverot"} / $opens{$s}->{"count"};
    $fracNoArchiveRot = $opens{$s}->{"noarchiverot"} / $opens{$s}->{"count"};
        if($live == 0 and $momento == 1) {$opens{$openaccess}->{"archiverot"}++;}
        if($live == 0 and $momento == 0) {$opens{$openaccess}->{"noarchiverot"}++;}
if($live == 1 and $momento == 0) {$opens{$openaccess}->{"liveNoArchive"}++;}
if($live == 1 and $momento == 1) {$opens{$openaccess}->{"liveArchive"}++;}    
  
   # print "$s\t$countLiveRot\t$fracLiveRot\t$fracArchive\t$fracArchiveRot\t$fracNoArchiveRot\n";

	$l1a1 = $opens{$s}->{"liveArchive"};
	$l0a1 = $opens{$s}->{"archiverot"};
	$a1 = $l1a1+$l0a1;
	$l1a0 = $opens{$s}->{"liveNoArchive"};
	$l0a0 = $opens{$s}->{"noarchiverot"};
	$a0 = $l1a0+$l0a0;
	$l1 = $l1a0+$l1a1;
	$l0 = $l0a0+$l0a1;
	$l = $l1+$l0;
	print "$s\n$l1a1\t$l0a1\t$a1\n$l1a0\t$l1a1\t$a0\n$l1\t$l0\t$l\n";

	$fl1a1 = $l1a1/$opens{$s}->{"count"};
	$fl0a1 = $l0a1/$opens{$s}->{"count"};
	$fa1 = $fl1a1+$fl0a1;
	$fl1a0 = $l1a0/$opens{$s}->{"count"};
	$fl0a0 = $l0a0/$opens{$s}->{"count"};
	$fa0 = $fl1a0+$fl0a0;
	$fl1 = $fl1a0+$fl1a1;
	$fl0 = $fl0a0+$fl0a1;
	$fl = $fl1+$fl0;
	print "$s\n$fl1a1\t$fl0a1\t$fa1\n$fl1a0\t$fl1a1\t$fa0\n$fl1\t$fl0\t$fl\n";
#	print "$s\t$fl0a1\t$fl0a0\t$fl1a0\t$fl1a1\n";
}

print "\n";


foreach $s(sort keys %urlLens) {
    $countLiveRot = $urlLens{$s}->{"count"} - $urlLens{$s}->{"live"};
    
    $fracLiveRot = $countLiveRot / $urlLens{$s}->{"count"};
    $fracArchive = $urlLens{$s}->{"momento"} / $urlLens{$s}->{"count"};
    $fracArchiveRot = $urlLens{$s}->{"archiverot"} / $urlLens{$s}->{"count"};
    $fracNoArchiveRot = $urlLens{$s}->{"noarchiverot"} / $urlLens{$s}->{"count"};
    
    print "$s\t$countLiveRot\t$fracLiveRot\t$fracArchive\t$fracArchiveRot\t$fracNoArchiveRot\n";
}

print "\n";

foreach $s(sort {$a <=> $b} keys %poses) {
    $countLiveRot = $poses{$s}->{"count"} - $poses{$s}->{"live"};
    
    $fracLiveRot = $countLiveRot / $poses{$s}->{"count"};
    $fracArchive = $poses{$s}->{"momento"} / $poses{$s}->{"count"};
    $fracArchiveRot = $poses{$s}->{"archiverot"} / $poses{$s}->{"count"};
    $fracNoArchiveRot = $poses{$s}->{"noarchiverot"} / $poses{$s}->{"count"};
    
    print "$s\t$countLiveRot\t$fracLiveRot\t$fracArchive\t$fracArchiveRot\t$fracNoArchiveRot\n";
}
