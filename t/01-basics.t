#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Komposita::Splitter;

plan tests => 18;

sub nope($) {
    return 0;
}

sub yep($) {
    return 1;
}

sub vwls($) {
    my ($str) = @_;
    
    return ($str =~ /^[aeiou]+$/);
}

sub cons($) {
    my ($str) = @_;
    return !vwls($str);
}

BEGIN {
    my $noper = Komposita::Splitter::new(\&nope, \&nope, \&nope);

    is_deeply($noper->(""),   [], "nope() should produce no splits");
    is_deeply($noper->("a"),  [], "nope() should produce no splits");
    is_deeply($noper->("aa"), [], "nope() should produce no splits");


    my $yepper = Komposita::Splitter::new(\&nope, \&yep, \&nope);

    is_deeply($yepper->(""),   [], "empty should produce no splits");
    is_deeply($yepper->("a"),
        [
            { match => "a" }
        ]);
    is_deeply($yepper->("ab"),
        [
            { match => "ab" },
            {
                prefix => "a", suffix => "b",
                ptree =>
                [
                    { match => "a" }
                ],
                stree => 
                [
                    { match => "b" }
                ]
            }
        ]);
    is_deeply($yepper->("abc"),
        [
            { match => "abc" },
            {
                prefix => "a", suffix => "bc",
                ptree => $yepper->("a"),
                stree => $yepper->("bc")
            },
            {
                prefix => "ab", suffix => "c",
                ptree => $yepper->("ab"),
                stree => $yepper->("c")
            },
        ]);


    my $vowels_only = Komposita::Splitter::new(\&nope, \&vwls, \&nope);
    
    is_deeply($vowels_only->("a"), 
        [
            { match => "a" },
        ]);

    is_deeply($vowels_only->("ab"), []);
    is_deeply($vowels_only->("ba"), []);
    is_deeply($vowels_only->("bb"), []);
    is_deeply($vowels_only->("aa"),
        [
            { match => "aa" },
            {
                prefix => "a", suffix => "a",
                ptree =>
                [
                    { match => "a" }
                ],
                stree => 
                [
                    { match => "a" }
                ]
            }
        ]);

    my $sorry = Komposita::Splitter::new(
        sub { return $_[0] eq 'ent'; },
        sub { return $_[0] eq 'schuldig'; },
        sub { return $_[0] eq 'ung'; });
    
    is_deeply($sorry->("ent"), []);
    is_deeply($sorry->("schuldig"),
            [
                {
                    match => "schuldig",
                }
            ]
        );
    is_deeply($sorry->("ung"), []);
    
    is_deeply($sorry->("entschuldig"),
            [
                {
                    prefix => "ent",
                    suffix => "schuldig",
                    ptree => $sorry->("ent"),
                    stree => $sorry->("schuldig")
                }
            ]
        );

    is_deeply($sorry->("schuldigung"),
            [
                {
                    prefix => "schuldig",
                    suffix => "ung",
                    ptree => $sorry->("schuldig"),
                    stree => $sorry->("ung")
                }
            ]
        );

    is_deeply($sorry->("entschuldigung"),
            [
                {
                    prefix => "ent",
                    suffix => "schuldigung",
                    ptree => $sorry->("ent"),
                    stree => $sorry->("schuldigung")
                },
                {
                    prefix => "entschuldig",
                    suffix => "ung",
                    ptree => $sorry->("entschuldig"),
                    stree => $sorry->("ung")
                }
            ]
        );
}

diag( "Testing Komposita::Splitter $Komposita::Splitter::VERSION, Perl $], $^X" );
