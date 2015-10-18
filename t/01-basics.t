#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Komposita::Splitter;

plan tests => 1;


BEGIN {
    my $splitter = Komposita::Splitter::new();

    is_deeply($splitter->(undef, undef, undef), [], "hi");
}

diag( "Testing Komposita::Splitter $Komposita::Splitter::VERSION, Perl $], $^X" );
