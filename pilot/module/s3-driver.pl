#!/usr/bin/perl

#  This software code is made available "AS IS" without warranties of any
#  kind.  You may copy, display, modify and redistribute the software
#  code either by itself or as incorporated into your code; provided that
#  you do not remove any proprietary notices.  Your use of this software
#  code is at your own risk and you waive any claim against Amazon
#  Digital Services, Inc. or its affiliates with respect to your use of
#  this software code. (c) 2006-2007 Amazon Digital Services, Inc. or its
#  affiliates.

use strict;
use warnings;

use S3::AWSAuthConnection;
use S3::QueryStringAuthGenerator;
use HTTP::Date;
use Data::Dumper;

my $AWS_ACCESS_KEY_ID = '<INSERT YOUR AWS ACCESS KEY ID HERE>';
my $AWS_SECRET_ACCESS_KEY = '<INSERT YOUR AWS SECRET ACCESS KEY HERE>';
# remove these next two lines as well, when you've updated your credentials.
print "update $0 with your AWS credentials\n";
exit;

my $conn = S3::AWSAuthConnection->new($AWS_ACCESS_KEY_ID, $AWS_SECRET_ACCESS_KEY);
my $generator = S3::QueryStringAuthGenerator->new($AWS_ACCESS_KEY_ID, $AWS_SECRET_ACCESS_KEY);

# Convert the bucket name to lower case in order to be able to use it with
# vanity domains (DNS is case-insenstitive).
my $BUCKET_NAME = lc "$AWS_ACCESS_KEY_ID-test-bucket";
my $KEY_NAME = 'test-key';


# Check if the bucket exists.  The high availability engineering of 
# Amazon S3 is focused on get, put, list, and delete operations. 
# Because bucket operations work against a centralized, global
# resource space, it is not appropriate to make bucket create or
# delete calls on the high availability code path of your application.
# It is better to create or delete buckets in a separate initialization
# or setup routine that you run less often.
if ($conn->check_bucket_exists($BUCKET_NAME)->http_response->code == 200) {
  print "----- bucket already exists! -----\n";
}
else {
  print "----- creating bucket -----\n";
  print $conn->create_bucket($BUCKET_NAME)->message, "\n";
  #  equiv to create_bucket($BUCKET_NAME)
  # print $conn->create_located_bucket($BUCKET_NAME, '')->message, "\n";
  #  create an EU bucket
  # print $conn->create_located_bucket($BUCKET_NAME, 'EU')->message, "\n";
}

print "----- bucket location -----\n";
print $conn->get_bucket_location($BUCKET_NAME)->location, "\n";

print "----- listing bucket -----\n";
print join(', ', map { $_->{Key} } @{$conn->list_bucket($BUCKET_NAME)->entries}), "\n";

print "----- putting object -----\n";
print $conn->put(
    $BUCKET_NAME,
    $KEY_NAME,
    S3::S3Object->new('this is a test'),
    { 'Content-Type' => 'text/plain' }
)->message, "\n";

print "----- getting object -----\n";
print $conn->get($BUCKET_NAME, $KEY_NAME)->object->data, "\n";

print "----- listing bucket -----\n";
print join(', ', map { $_->{Key} } @{$conn->list_bucket($BUCKET_NAME)->entries}), "\n";


print "----- query string auth example -----\n";
$generator->expires_in(60);
print "\nTry this url out in your browser (it will only be valid for 60 seconds).\n\n";
my $url = $generator->get($BUCKET_NAME, $KEY_NAME);
print "$url\n";
print "\npress enter> ";
getc;

print "\nNow try just the url without the query string arguments.  it should fail.\n\n";
print substr($url, 0, index($url, '?')), "\n";
print "\npress enter> ";
getc;


print "----- putting object with metadata and public read acl -----\n";
print $conn->put(
    $BUCKET_NAME,
    "$KEY_NAME-public",
    S3::S3Object->new('this is a publicly readable test', { blah => 'foo' }),
    { 'x-amz-acl' => 'public-read', 'Content-Type' => 'text-plain' }
)->message, "\n";


print "----- anonymous read test ----\n";
print "\nYou should be able to try this in your browser\n\n";
my $public_url = $generator->get($BUCKET_NAME, "$KEY_NAME-public");
print substr($public_url, 0, index($public_url, "?")), "\n";
print "\npress enter> ";
getc;

print "----- path style url example -----";
print "\nNon-location-constrained buckets can also be specified as part of the url path.  (This was the original url style supported by S3.)\n\n";
print "\nTry this url out in your browser (it will only be valid for 60 seconds).\n\n";
$generator->set_calling_format("PATH");
my $subdomain_url = $generator->get($BUCKET_NAME, $KEY_NAME);
print "$subdomain_url\n";
print "\npress enter> ";
getc;

print "----- getting object's acl -----\n";
print $conn->get_acl($BUCKET_NAME, $KEY_NAME)->object->data, "\n";

print "----- deleting objects -----\n";
print $conn->delete($BUCKET_NAME, $KEY_NAME)->message, "\n";
print $conn->delete($BUCKET_NAME, "$KEY_NAME-public")->message, "\n";

print "----- listing bucket -----\n";
print join(', ', map { $_->{Key} } @{$conn->list_bucket($BUCKET_NAME)->entries}), "\n";

print "----- listing all my buckets -----\n";
print join(', ', map { $_->{Name} } @{$conn->list_all_my_buckets()->entries}), "\n";

print "----- deleting bucket -----\n";
print $conn->delete_bucket($BUCKET_NAME)->message, "\n";
