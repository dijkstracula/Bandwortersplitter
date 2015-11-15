#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Komposita::Splitter;
use Komposita::Transform;

plan tests => 9;

sub nope($) {
    return 0;
}

sub yep($) {
    return 1;
}

sub identity($) {
    return $_[0];
}

sub match_times_three($) {
    return {match => $_[0]->{match} x 3};
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

    is_deeply({}, 
        Komposita::Transform::map(\&identity, {}));
    is_deeply({match => "a"},
        Komposita::Transform::map(\&identity, {match => "a"}));
    is_deeply({match => "aaa"},
        Komposita::Transform::map(\&match_times_three, { match => "a" }));

    is_deeply({},
        Komposita::Transform::filter(\&yep, {}));
    is_deeply({match => "a"},
        Komposita::Transform::filter(\&yep, {match => "a"}));

    is_deeply(undef,
        Komposita::Transform::filter(\&nope, {}));
    is_deeply(undef,
        Komposita::Transform::filter(\&nope, {match => "a"}));
}

diag( "Testing Komposita::Transform $Komposita::Transform::VERSION, Perl $], $^X" );
