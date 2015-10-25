#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Komposita::Splitter;
use Komposita::Transform;

plan tests => 3;

sub identity($) {
    return $_[0];
}

sub trim { my $s = shift; $s =~ s/\s//g; return $s };

BEGIN {
    isnt(Komposita::Transform::_is_leaf({
                    prefix => "a", suffix => "b",
                    ptree => [ { match => "a" } ],
                    stree => [ { match => "b" } ]
                }), 0);
    is(Komposita::Transform::_is_leaf(
            { match => "a" }), 1);

    is_deeply([], Komposita::Transform::map(\&identity, []));
}

diag( "Testing Komposita::Transform $Komposita::Transform::VERSION, Perl $], $^X" );
