#!/usr/bin/perl
# a small toolkit to genenrate summary files
# according to condense format of extracted links
# and abstract file (meta-data)
#
# ARGV[0] -- abstract file path
# ARGV[1] -- condense extracted link file path
# ARGV[2] -- summary file directory (output)
# ARGV[3] -- duplink file path (for analysis, output)

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


# read all date info and store in memory (hash)

open ABS, "<$ARGV[0]" or die "can't open abstract files\n";

            undef $pubid; undef $pubDate;
	$pushFlag = 0;
            while($line = <ABS>) {
		if($line =~ /(.*?).abs$/) {
			$pubid = $1;
		}

                #if($line =~ /arXiv:(.*?)\/(.*)/) {
                if($line =~ /arXiv:(.*)/) {
			$allid = $1; chomp $allid;
			if($allid =~ /(.*?)\/(.*)/) {
				$dom = $1; $id = $2; chomp $id;
				$pubid = $dom."|".$id;
			}
			else {$pubid = "arxiv".$allid;}
		}
                if($line =~ /Date\s*?(.*?):(.*?)\(/) {
                    $dateType = $1; $d = $2;
                    if($dateType =~ /\(/) {;}
                    else {$dateType = "(first submission)";}

                    $d =~ s/^\s+|\s+$//g;
                    if(!defined $pubDate) {$pubDate = "$d\t$dateType";}
                    else {$pubDate = $pubDate . ";$d\t$dateType";}
                }
                if($line =~ /Title: (.*)/) {
                    $title = $1; chomp $title;
			while(1) {
                        	$line = <ABS>;
                        	if($line =~ /^Authors/) {last;}
                        	else {
                                chomp $line;
                                $title = $title.$line;
                        	}
                	}
                	$title =~ s/\s+/ /g;
                }
                if($line =~ /Authors: (.*)/) {
                    $author = $1; chomp $author;
                }
                if($line =~ /Categories: (.*)/) {
                    $cat = $1; chomp $cat;
		    $pushFlag = 1;
                }
         
            	if(defined $pubid and $pushFlag == 1) {
                	print "$pubid\t$pubDate\t$title\t$author\t$cat\n";
                	${$pubAbsMaps{$pubid}}{"date"} = $pubDate;
                	${$pubAbsMaps{$pubid}}{"title"} = $title;
                	${$pubAbsMaps{$pubid}}{"author"} = $author;
                	${$pubAbsMaps{$pubid}}{"cat"} = $cat;
			$pushFlag = 0;
			undef $pubid; undef $dateType; undef $pubDate; undef $title; undef $author; undef $cat;
		}

            }
close ABS;


open URL, "<$ARGV[1]" or die "can't open link files $ARGV[1]";
while($line = <URL>) {
    if($line =~ /(.*?).pdf.xml: (.*)/) {
        $pubid = $1; $url = $2; chomp $url;
	if($pubid =~ /^\d/) {$pubid = "arxiv".$pubid;}
	else {;}
	if($pubid =~ /(.*?)v\d+$/) {$pubid = $1;}
        $pubURLs{$pubid}{$url} = 1;
    }
}
close URL;

open DUPLINKS, ">$ARGV[3]" or die "can't open dup link for writing for analysis\n";


$numLinks = 0;
foreach $pubid(sort keys %pubURLs) { 
    $fileName = $pubid.".summary";
	
	# filter out some years if we don't want, 
	# here pubids < 97 or > 12
	if($pubid =~ /[a-zA-Z\-]*?(\d\d)/) {
		$year = $1;
		if($year < 97) {
			if($year > 12) {
				next;
			}
			else {;}
		}
		else {;}
	}


    open OUT, ">$ARGV[2]/$fileName" or die "can't open output file $ARGV[2]/$fileName";
    $title = ${$pubAbsMaps{$pubid}}{"title"};
    $author = ${$pubAbsMaps{$pubid}}{"author"};
    $cat = ${$pubAbsMaps{$pubid}}{"cat"};
    $pubDate = ${$pubAbsMaps{$pubid}}{"date"};
    
	$title =~ s/&/&amp;/g; $title =~ s/</&lt;/g;
	$author =~ s/&/&amp;/g; $author =~ s/</&lt;/g;
	$cat =~ s/&/&amp;/g; $cat =~ s/</&lt;/g;
	$pubDate =~ s/&/&amp;/g; $pubDate =~ s/</&lt;/g;

    print OUT "<document id=\"$pubid\">\n\t<title>$title</title>\n\t<authors>$author</authors>\n\t<categories>$cat</categories>\n\t<dates>\n";
if(!defined ${$pubAbsMaps{$pubid}}{"date"}) {
	if($pubid =~ /[a-zA-Z]+(\d\d)(\d\d)/) {
		$y = $1; $m = $2;
		if($y > 90) {$y = "19".$y;}
		else {$y = "20".$y;}
		$m = $monthMaps{$m};
		print OUT "\t\t<date type=\"unknown\">1 $m $y GMT</date>\n";
	}
}
else {
    @pubDates = split /;/, $pubDate;
    foreach $date(@pubDates) {
        ($d, $type) = split /\t/, $date;
        $type =~ s/\(//g; $type =~ s/\)//g;
        print OUT "\t\t<date type=\"$type\">$d</date>\n";
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

