#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use Net::Google::Calendar;

my $parent = Net::Google::Calendar->new;
#$parent->login('claves.doamaral@gmail.com', '7D3alRoad');
my $response = $parent->auth('535230210581-88qbui2l60qj05q6mj8hlkt02dokb92h.apps.googleusercontent.com', 'API Project-ad911dc6fcaf.json');

print Dumper $response;

my @cals = $parent->get_calendars;
