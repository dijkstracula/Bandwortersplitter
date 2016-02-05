#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Quatsch::Splitter' ) || print "Bail out!\n";
}

diag( "Testing Quatsch::Splitter $Quatsch::Splitter::VERSION, Perl $], $^X" );
