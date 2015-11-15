package Bandwordersplitter::Translator;

use strict;
use warnings;

use Data::Dumper;
use Komposita::Splitter;
use Net::Dict;

#TODO: this should be configurable to use
#localhost.
my $dict = Net::Dict->new("localhost");
$dict->setDicts('fd-deu-eng');

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
            exists($prefixes->{$_[0]}) ||
            exists($words->{$_[0]}) ||
            exists($suffixes->{$_[0]});
        },
        sub {
            exists($suffixes->{$_[0]});
        }
    );
}

sub translate($) {
	my $res = $dict->define($_[0]);
	return "?" unless defined $res;
	return "?" unless defined $res->[0];

	my @defn = split("\n", $res->[0]->[1]); # "word IPA \n translations"
	return $defn[1];
}
