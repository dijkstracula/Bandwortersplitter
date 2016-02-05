#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Komposita::Splitter' ) || print "Bail out!\n";
}

diag( "Testing Komposita::Splitter $Komposita::Splitter::VERSION, Perl $], $^X" );
