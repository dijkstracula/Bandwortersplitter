#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Komposita::Splitter;

plan tests => 2;

sub nope($) {
    return 0;
}

sub yep($) {
    return 1;
}

sub trim { my $s = shift; $s =~ s/\s//g; return $s };

BEGIN {
    my $yepper = Komposita::Splitter::new(\&nope, \&yep, \&nope);

    is_deeply(Komposita::Splitter::tree_as_json($yepper->("")), "[]");
    is_deeply(Komposita::Splitter::tree_as_json($yepper->("a")),
        trim('[
            { "match" : "a" }
        ]'));
}

diag( "Testing Komposita::Splitter $Komposita::Splitter::VERSION, Perl $], $^X" );
