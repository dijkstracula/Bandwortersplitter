#!perl -T
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::More;

use Quatsch::Splitter;
use Quatsch::Transform;

plan tests => 6;

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
	my ($node) = @_;
	my $new_node = {%$node};
	$new_node->{slice} = $node->{slice} x 3;
	return $new_node;
}

sub trim { my $s = shift; $s =~ s/\s//g; return $s };

sub make_nomatch($) {
	my ($word) = @_;
	return { slice => $word, splits => [] };
}

sub make_match($) {
	my ($word) = @_;
	return { slice => $word, match => 1, splits => [] };
}

BEGIN {
    isnt(Quatsch::Transform::_is_leaf(
			{slice => "hi", splits => ["some_splits_here"]}), 0);
    is(Quatsch::Transform::_is_leaf(make_match("abc")), 1);

    is_deeply(make_match("a"),
        Quatsch::Transform::map(\&identity, make_match("a")));
	is_deeply(make_match("aaa"),
	    Quatsch::Transform::map(\&match_times_three, make_match("a")));

	is_deeply( { slice => "ab", 
			     splits => [
					{ ptree => { slice => "a", splits => []},
					  stree => { slice => "b", splits => []}}
				 ]},
			 Quatsch::Transform::map(\&identity, 
				 { slice => "ab", 
			       splits => [
					{ ptree => { slice => "a", splits => []},
					  stree => { slice => "b", splits => []}}
				 ]}));

	is_deeply( { slice => "ababab", 
			     splits => [
					{ ptree => { slice => "aaa", splits => []},
					  stree => { slice => "bbb", splits => []}}
				 ]},
			 Quatsch::Transform::map(\&match_times_three, 
				 { slice => "ab", 
			       splits => [
					{ ptree => { slice => "a", splits => []},
					  stree => { slice => "b", splits => []}}
				 ]}));

	# TODO
	#is_deeply(make_match("a"),
	#    Quatsch::Transform::filter(\&yep, make_match("a")));
}

diag( "Testing Quatsch::Transform $Quatsch::Transform::VERSION, Perl $], $^X" );
