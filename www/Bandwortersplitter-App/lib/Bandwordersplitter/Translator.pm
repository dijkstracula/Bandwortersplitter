package Bandwordersplitter::Translator;

use strict;
use warnings;

use Data::Dumper;
use Encode qw(decode encode);
use Komposita::Splitter;
use Net::Dict;

#TODO: this should be configurable to use
#localhost.
my $dict = Net::Dict->new("localhost");
$dict->setDicts('fd-deu-eng', 'german-english');

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
    return Komposita::Splitter::new(
        sub {
            exists($prefixes->{$_[0]});
        },
        sub {
			my ($word) = @_;
			my $exists = exists($words->{$word});

			# Try and match a prefix or a suffix so long as it
			# isn't a super short one like '-e' or '-en'.
			if (!$exists && length($word) >= 3) {
            	$exists ||= exists($prefixes->{$_[0]});
            	$exists ||= exists($suffixes->{$_[0]});
			}

			return $exists;
        },
        sub {
            exists($suffixes->{$_[0]});
        }
    );
}

sub translate($) {
	#TODO: Encoding this makes no sense
	my $word = encode('UTF-8', $_[0], Encode::FB_DEFAULT);
	my $res = $dict->define($word);
	return "?" unless defined $res;
	return "?" unless defined $res->[0];

	$res = $res->[0];
	my @lines = split("\n", $res->[1]);
	return decode('UTF-8', $lines[-1], Encode::FB_DEFAULT);
}
