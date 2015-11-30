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


sub make_nomatch($) {
	my ($word) = @_;
	{ slice => $word, splits => [] };
}

sub make_match($) {
	my ($word) = @_;
	{ slice => $word, match => 1, splits => [] };
}

BEGIN {
    my $noper = Komposita::Splitter::new(\&nope, \&nope, \&nope);
	my $empty = { splits => [] };

    is_deeply($noper->(""),   make_nomatch(""), "nope() should produce no splits");
    is_deeply($noper->("a"),  make_nomatch("a"), "nope() should produce no splits");
    is_deeply($noper->("aa"), make_nomatch("aa"), "nope() should produce no splits");


    my $yepper = Komposita::Splitter::new(\&nope, \&yep, \&nope);

    is_deeply($yepper->(""),   make_nomatch(""), "empty should produce no splits");
    is_deeply($yepper->("a"), make_match("a"));
    is_deeply($yepper->("ab"),
            { slice => "ab",
			  match => 1,
			  splits => 
			  [
				  {
					  ptree => make_match("a"),
					  stree => make_match("b")
				  }
			  ]
            });
    is_deeply($yepper->("abc"),
            { slice => "abc",
			  match => 1,
			  splits => 
			  [
				  {
					  ptree => $yepper->("a"),
					  stree => $yepper->("bc")
		  	      },
				  {
					  ptree => $yepper->("ab"),
					  stree => $yepper->("c")
		  	      },
			  ]
            });


    my $vowels_only = Komposita::Splitter::new(\&nope, \&vwls, \&nope);
    
    is_deeply($vowels_only->("a"), make_match("a"));

	#is_deeply($vowels_only->("ab"), make_nomatch("ab"));
	#is_deeply($vowels_only->("ba"), make_nomatch("ba"));
    is_deeply($vowels_only->("bb"), make_nomatch("bb"));
    is_deeply($vowels_only->("aa"),
            { slice => "aa",
			  match => 1,
			  splits =>
			  [
				  {
					  ptree => make_match("a"),
					  stree => make_match("a")
				  }
			  ]
            });

    my $sorry = Komposita::Splitter::new(
        sub { return $_[0] eq 'ent'; },
        sub { return $_[0] eq 'schuldig'; },
        sub { return $_[0] eq 'ung'; });
    
    is_deeply($sorry->("ent"), make_nomatch("ent"));
    is_deeply($sorry->("schuldig"), make_match("schuldig"));
    is_deeply($sorry->("ung"), make_nomatch("ung"));
    
    is_deeply($sorry->("entschuldig"),
                {
					slice => "entschuldig",
					splits => 
					[
						{
							ptree => $sorry->("ent"),
							stree => $sorry->("schuldig")
						}
					]
                });

    is_deeply($sorry->("schuldigung"),
                {
					slice => "schuldigung",
					splits =>
					[
						{
							ptree => $sorry->("schuldig"),
							stree => $sorry->("ung")
						}
					]
                });

	is_deeply($sorry->("entschuldigung"),
			   {
				   slice => "entschuldigung",
				   splits => 
				   [
						{
							ptree => $sorry->("entschuldig"),
							stree => $sorry->("ung")
						},
						{
							ptree => $sorry->("ent"),
							stree => $sorry->("schuldigung")
						},
				   ]
			   });


    my $friendly = Komposita::Splitter::new(
		\&nope,
        sub { return $_[0] eq 'freund'; },
        sub { return $_[0] eq 's'; });

	is_deeply($friendly->("freund"),
			   {
			       slice => "freund",
				   match => 1,
				   splits => []
			   });
	is_deeply($friendly->("freunds"),
			   {
				   slice => "freunds",
				   splits =>
				   [
						{
						   ptree => $friendly->("freund"),
						   stree => $friendly->("s")
						}
				   ]
			   });
}

diag( "Testing Komposita::Splitter $Komposita::Splitter::VERSION, Perl $], $^X" );
