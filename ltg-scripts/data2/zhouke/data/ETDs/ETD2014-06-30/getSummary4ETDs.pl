#!/usr/bin/perl
# a small toolkit to genenrate summary files
# according to condense format of extracted links
# and abstract file (meta-data)
#
# ARGV[0] -- condensed link with meta file path
# ARGV[1] -- summary file directory (output)
# ARGV[2] -- duplink file path (for analysis, output)

%monthMaps=(
"01"=>"Jan",
"02"=>"Feb",
"03"=>"Mar",
"04"=>"Apr",
"05"=>"May",
"06"=>"Jun",
"07"=>"Jul",
"08"=>"Aug",
"09"=>"Sep",
"10"=>"Oct",
"11"=>"Nov",
"12"=>"Dec",
);


open LINKWITHMETA, "<$ARGV[0]" or die;
while($line = <LINKWITHMETA>) {
    if($line =~ /(.*?).pdf.xml\t(.*?)\t(.*?)\t(.*?)\t(.*)/) {
        $pubid = $1; $url = $2; 
	$sub = $3; $pubDate = $4; 
	$type = $5; chomp $type;
        $pubURLs{$pubid}{$url} = 1;
	${$pubAbsMaps{$pubid}}{"date"} = $pubDate;
	${$pubAbsMaps{$pubid}}{"sub"} = $sub;
	${$pubAbsMaps{$pubid}}{"cat"} = $type;
    }
}
close LINKWITHMETA;


open DUPLINKS, ">$ARGV[2]" or die "can't open dup link for writing for analysis\n";


$numLinks = 0;
foreach $pubid(sort keys %pubURLs) { 
    $fileName = $pubid.".summary";
	

    open OUT, ">$ARGV[1]/$fileName" or die "can't open output file $ARGV[1]/$fileName";
    $sub = ${$pubAbsMaps{$pubid}}{"sub"};
    $cat = ${$pubAbsMaps{$pubid}}{"cat"};
    $pubDate = ${$pubAbsMaps{$pubid}}{"date"};
	
	$sub =~ s/&/&amp;/g; $sub =~ s/</&lt;/g;
	$cat =~ s/&/&amp;/g; $cat =~ s/</&lt;/g;
	$pubDate =~ s/&/&amp;/g; $pubDate =~ s/</&lt;/g;

    	print OUT "<document id=\"$pubid\">\n\t<categories>$cat</categories>\n\t<subject>$sub</subject>\n\t<dates>\n";
	if(!defined ${$pubAbsMaps{$pubid}}{"date"}) {
		print OUT "\t\t<date type=\"unknown\"></date>\n";
	}

	else {
		if($pubDate =~ /(.*?)-(.*?)-(.*)/) {
			$y = $1; $m = $2; $d = $3;
			$month = $monthMaps{$m};
			$date = $month." ".$d." ".$y." 12:00:00";
        		print OUT "\t\t<date type=\"first submission\">$date</date>\n";
		}
    	}
    	print OUT "\t</dates>\n\t<links>\n";

    undef @prevLinks;
    foreach $link(keys %{$pubURLs{$pubid}}) {
        $link =~ s/\/$//;
	$link =~ s/&/&amp;/g; $link =~ s/</&lt;/g;
        $dup = 0;
        # de-duplicate links
        foreach $l(@prevLinks) {
            if($link eq $l) {
                $dup = 1;
                print DUPLINKS "$pubid\t$link\t$l\n";
                last;
            }
        }
        if($dup == 0) {
            print OUT "\t\t<link>$link</link>\n";
            $numLinks++;
        }
        push @prevLinks, $link;
    }
    print OUT "\t</links>\n</document>\n";
    close OUT;
}
print "Total Number of Links Extracted: $numLinks\n";

close DUPLINKS;

