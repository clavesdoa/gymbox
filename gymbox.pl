#!/usr/bin/perl -w

use strict;
use warnings;
use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;

die "Usage: $0 [date] [class] [instance]\n" if @ARGV < 3;

my $mech = WWW::Mechanize->new();
WWW::Mechanize::TreeBuilder->meta->apply($mech);

my $loginUrl = 'https://gymbox.legendonlineservices.co.uk/enterprise/account/Login';
my $timetableUrl = 'https://gymbox.legendonlineservices.co.uk/enterprise/BookingsCentre/MemberTimetable';
my $bookUrl = 'https://gymbox.legendonlineservices.co.uk/enterprise/BookingsCentre/AddBooking?booking=';
my $paymentUrl = 'https://gymbox.legendonlineservices.co.uk/enterprise/Basket/Pay';
my $pollStatusUrl = 'https://gymbox.legendonlineservices.co.uk/enterprise/ajax/DirtyPollStatus';
my $payConfirmUrl = 'https://gymbox.legendonlineservices.co.uk/enterprise/basket/PaymentConfirmed';
my $date = $ARGV[0];
my $class = $ARGV[1];
my $instance = $ARGV[2];

print "Logging in...\n";
$mech->get($loginUrl);
$mech->submit_form(
    form_number => 1,
    fields      => { 'login.Email' => 'xxx@xxx', 'login.Password' => 'xxx' },
);
die "Error: Couldn't login $!\n" unless ($mech->success);

print "Getting time table...\n";
$mech->get($timetableUrl);
die "Error: Couldn't open $timetableUrl $!\n" unless ($mech->success);

my $timeTable = $mech->look_down(_tag => 'table', id => 'MemberTimetable');
my @tableRows = $timeTable->look_down(_tag => 'tr');
my $nextClass;
my $afterDate = 0;
for my $i (0 .. $#tableRows) {
	next unless $afterDate || $tableRows[$i]->as_text =~ qr/$date/;
	$afterDate = 1;
	next unless $tableRows[$i]->as_text =~ qr/$class/ && --$instance == 0;
	$nextClass = $tableRows[$i];
	last;
}
die "Error: Couldn't find next class $!\n" unless (defined $nextClass );

print "Booking...\n";
my $nextBook = $nextClass->look_down(_tag => 'a', sub { $_[0]->as_text =~ qr/Book/ });
die "Error: Couldn't find next booking link $!\n" unless (defined $nextBook );

my $bookId = $nextBook->attr('id');
$bookId =~ qr/slot(\d+)/;
die "Error: Couldn't get booking Id: $bookId $!\n" unless (defined $1);

my $random = rand();
my $bookingUrl = $bookUrl.$1.'&ajax='.$random;
$mech->get($bookingUrl);
die "Error: Couldn't perform next booking $bookingUrl $!\n" unless ($mech->success );

$mech->get($paymentUrl);
die "Error: Couldn't perform payment $!\n" unless ($mech->success );

$mech->get($pollStatusUrl);
die "Error: Couldn't check status $!\n" unless ($mech->success );

$mech->get($payConfirmUrl);
die "Error: Couldn't confirm payment $!\n" unless ($mech->success );

print "Success\n";
