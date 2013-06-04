#!/usr/local/bin/perl

# This software code is made available "AS IS" without warranties of any
# kind.  You may copy, display, modify and redistribute the software
# code either by itself or as incorporated into your code; provided that
# you do not remove any proprietary notices.  Your use of this software
# code is at your own risk and you waive any claim against Amazon
# Digital Services, Inc. or its affiliates with respect to your use of
# this software code. (c) 2006-2007 Amazon Digital Services, Inc. or its
# affiliates.

use strict;

use S3;
use S3::AWSAuthConnection;
use S3::QueryStringAuthGenerator;
use Getopt::Std;
use File::Basename;
use XML::Simple;

my %opts = ();
getopt('b:k:f:c:', \%opts);

my $cfg=XMLin($opts{'c'} || 'aws_config.xml');
my $AWS_ACCESS_KEY_ID = $cfg->{access_key_id};
my $AWS_SECRET_ACCESS_KEY = $cfg->{secret_access_key};

# For subdomains (bucket.s3.amazonaws.com), the bucket name must be lowercase
# since DNS is case-insensitive.

my $conn =
    S3::AWSAuthConnection->new($AWS_ACCESS_KEY_ID, $AWS_SECRET_ACCESS_KEY);

my $BUCKET_NAME;
if ($opts{'b'} eq '') {
   $BUCKET_NAME = "arxiv";
} else {
   $BUCKET_NAME = lc $opts{'b'};
}
if ($opts{'k'} eq '') {
   print "Please specify a key to retrieve with -k flag\n";
   print "Optionally, you can specify bucket with -b flag\n";
   exit;
}
my $key = $opts{'k'};
my $filename = $opts{'f'} || $opts{'k'};
my $response = $conn->get($BUCKET_NAME, $key, {'x-amz-request-payer' => 'requester'});

if ($response->http_response->code == 200) {
   if (open(my $outfh, '>', $filename)) {
     print {$outfh} $response->object->data;
     close($outfh);
     print "successfully downloaded file to $filename\n";
   } else {
     die "Failed to write downloaded file to $filename: $!";
   }
} else {
   print "Failed to download file\n";
   print "response code: ".$response->http_response->code."\n";
   print "response: " . $response->body;
}
