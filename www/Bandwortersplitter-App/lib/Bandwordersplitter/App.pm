package Bandwordersplitter::App;

use Bandwordersplitter::Translator;
use Dancer2;
use Data::Dumper;
use Komposita::Splitter;

our $VERSION = '0.1';

$Data::Dumper::Indent = 3;

get '/' => sub {
    template 'index';
};

get '/split/:q' => sub {
    my $query = lc(params->{"q"});
    die "missing parameter" unless $query;

    my $splitter = Bandwordersplitter::Translator::new_de_splitter();

	$Data::Dumper::Indent = 3;       # pretty print with array indices
	$Data::Dumper::Useqq = 1;        # print strings in double quotes

	template 'result', { tree => Dumper($splitter->($query)) }
};

true;
