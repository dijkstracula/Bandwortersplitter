package Bandwordersplitter::Translator;

use strict;
use warnings;

use Dancer2;
use Data::Dumper;
use Encode qw(decode encode);
use Quatsch::Splitter;
use List::MoreUtils qw(uniq);
use Memoize;
use Net::Dict;

sub file_to_set {
    my $path = shift;
    my %set;

    open (my $fd, "<:encoding(UTF-8)", $path) or die "Can't open $path";
   
    while (my $line = <$fd>) {
        chomp $line;
        $set{lc($line)}++;
    }

    return \%set;
}

my $prefixes = file_to_set("db/de_prefixes.txt");
my $words = file_to_set("db/de_words.txt");
my $suffixes = file_to_set("db/de_suffixes.txt");

sub new_de_splitter {
    return Quatsch::Splitter::new(
        sub {
            exists($prefixes->{$_[0]});
        },
        sub {
			my ($word) = @_;
			my $exists = exists($words->{$word});

			# Try and chop off a leading 's' in the case that it's a possessive
			# word combination (e.g. for unabhängigkeit_s_erklärung
			if (!$exists && substr $word, -1 eq 's') {
   	        	$exists ||= exists($words->{substr $word, 0, -1});
			}

			return $exists;
        },
        sub {
            exists($suffixes->{$_[0]});
        }
    );
}

sub translate($) {
	#TODO: this should be configurable to use
	#localhost.
	my $dict = Net::Dict->new("localhost");
	die "Can't connect to dict" unless $dict;
	$dict->setDicts('fd-deu-eng', 'german-english');

	#TODO: Encoding this makes no sense
	my $word = encode('UTF-8', $_[0], Encode::FB_DEFAULT);
	my $defns = $dict->define($word);
	my @ret;
	my $len = 0;

	return undef unless defined $defns;
	return undef unless defined $defns->[0];

	my @sorted = sort {
		length($a->[1]) <=> length($b->[1])
	} @$defns;

	for my $defn (@sorted) {
		last if $len > 75;
		my @lines = split("\n", $defn->[1]);

		my $stripped = $lines[-1];
		$stripped =~ s/^\s+|\s+$//g;

		push @ret, decode('UTF-8', $stripped, Encode::FB_DEFAULT);
		$len += length($stripped);
	}
	return join '; ', uniq(@ret);
}

# Given a split node (e.g. an object with a $slice and \@splits), 
# produce a four-tuple
sub create_translated_node($) {
	my ($node) = @_;
	die unless defined $node->{slice};

	my $new_node = { 
		de => $node->{slice},
		en => Bandwordersplitter::Translator::translate($node->{slice}),
		ok_trans => 0,
		total_trans => 1,
	};
		
	if (defined $new_node->{en} || $new_node->{de} eq 's') {
		$new_node->{valid} = 1;
		$new_node->{ok_trans}++;
	}

	return $new_node unless scalar(@{$node->{splits}}) > 0;

	# Take the split that we were able to find the most
	# translations for word splits.
	my $best_trans_ratio = -1;
	my $best_split;

	for my $s (@{$node->{splits}}) {
		my $ratio;
		if (not defined $s->{ptree} || not defined $s->{stree}) {
			$ratio = 0;
		} elsif ($s->{ptree}->{valid} && $s->{stree}->{valid}) {
			$ratio = 1;
		} else {
			$ratio = ($s->{ptree}->{ok_trans} + $s->{stree}->{ok_trans}) / 
					 ($s->{ptree}->{total_trans} + $s->{stree}->{total_trans});
		}
		if ($ratio > $best_trans_ratio) {
			$best_split = $s;
			$best_trans_ratio = $ratio;
		}
	}

	$new_node->{split} = $best_split;
	$new_node->{ok_trans} += $best_split->{ptree}->{ok_trans} + $best_split->{stree}->{ok_trans};
	$new_node->{total_trans} += $best_split->{ptree}->{total_trans} + $best_split->{stree}->{total_trans};

	# We also consider a node to be valid if both its split's children are valid.
	if ($new_node->{de} eq 's' || 
		($best_split->{ptree}->{valid} && $best_split->{stree}->{valid})) {
		$new_node->{valid} = 1;
	}

	return $new_node;
}

sub normalize_node {
	my ($node) = @_;
	$node->{slice};
}
memoize('create_translated_node', NORMALIZER => 'normalize_node');
