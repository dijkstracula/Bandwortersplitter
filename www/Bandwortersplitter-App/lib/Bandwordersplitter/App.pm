package Bandwordersplitter::App;

use Bandwordersplitter::Translator;
use Dancer2;
use Data::Dumper;
use Komposita::Splitter;

our $VERSION = '0.1';

$Data::Dumper::Indent = 3;

# TODO: I don't know what file this should go into
sub tree_as_table($%) {
	my ($tree) = @_;
	my @ret;

	push @ret, "<table>";

	if (exists $tree->{match}) {
		push @ret, "<tr>" . $tree->{match} . "</tr>";
	}

	push @ret, "<tr>";

	if (exists $tree->{ptree}) {
		push @ret, "<td>";
		push @ret, tree_as_table($tree->{ptree});
		push @ret, "</td>";
	}

	if (exists $tree->{stree}) {
		push @ret, "<td>";
		push @ret, tree_as_table($tree->{stree});
		push @ret, "</td>";
	}

	push @ret, "</tr>";

	push @ret, "</table>";

	return join("\n", @ret);
}


get '/' => sub {
    template 'index';
};

get '/split/:q' => sub {
    my $query = lc(params->{"q"});
    die "missing parameter" unless $query;

    my $splitter = Bandwordersplitter::Translator::new_de_splitter();

	$Data::Dumper::Indent = 3;       # pretty print with array indices
	$Data::Dumper::Useqq = 1;        # print strings in double quotes

	template 'result', { tree => tree_as_table($splitter->($query)) }
};

true;
