#! /usr/bin/perl
#---------------------------------------------------------------------
# $Id$
# Copyright 1998 Christopher J. Madsen
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# Test the MSDOS::Descript module
#---------------------------------------------------------------------
######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded;}
use MSDOS::Descript;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use FindBin '$Bin';
chdir $Bin or die "Unable to cd $Bin: $!";

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my @files = (qw(alpha beta gamma delta epsilon), 'alpha omega');

my $d = MSDOS::Descript->new('sample.des');
my $test = 1;

foreach (@files) {
    my $desc = "This is $_";
    print 'not ' unless $d->description($_) eq $desc
                 and $d->description(uc $_) eq $desc;
    ++$test; print "ok $test\n";
}

$d->rename('delta','wasdelta');
print 'not ' unless not defined($d->description('delta'))
             and $d->description('wasdelta') eq 'This is delta';
++$test; print "ok $test\n";

$d->description('beTA', 'New');
print 'not ' unless $d->description('Beta') eq 'New';
++$test; print "ok $test\n";

$d->description('BEta', '');
print 'not ' if defined $d->description('beta');
++$test; print "ok $test\n";

$d->description('GAMMA', undef);
print 'not ' if defined $d->description('gamma');
++$test; print "ok $test\n";

$d->write('delete.me');

my $d2 = MSDOS::Descript->new('delete.me');
foreach ('Alpha', 'EPSILON', 'WasDelta', 'Alpha Omega') {
    print 'not ' unless $d->description($_) eq $d2->description($_);
    ++$test; print "ok $test\n";
}
unlink 'delete.me';
