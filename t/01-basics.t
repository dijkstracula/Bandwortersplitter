#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Komposita::Splitter;

plan tests => 7;

sub nope($) {
    return 0;
}

sub yep($) {
    return 1;
}

sub vwls($) {
    my ($str) = @_;
    return ($str =~ /[aeiou]+/);
}

BEGIN {
    my $noper = Komposita::Splitter::new(\&nope, \&nope, \&nope);

    is_deeply($noper->(""),   [], "nope() should produce no splits");
    is_deeply($noper->("a"),  [], "nope() should produce no splits");
    is_deeply($noper->("aa"), [], "nope() should produce no splits");

    my $yepper = Komposita::Splitter::new(\&nope, \&yep, \&nope);

    is_deeply($yepper->(""),   [], "empty should produce no splits");
    is_deeply($yepper->("a"),
        []);
    is_deeply($yepper->("ab"),
        [
            {
                prefix => "a", suffix => "b",
                ptree => [],
                stree => [],
            }
        ]);
    is_deeply($yepper->("abc"),
        [
            {
                prefix => "a", suffix => "bc",
                ptree => [],
                stree => $yepper->("bc")
            },
            {
                prefix => "ab", suffix => "c",
                ptree => $yepper->("ab"),
                stree => []
            },
        ]);
}

diag( "Testing Komposita::Splitter $Komposita::Splitter::VERSION, Perl $], $^X" );
