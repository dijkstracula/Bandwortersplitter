package Bandwordersplitter::App;

use Bandwordersplitter::Translator;
use Dancer2;
use Data::Dumper;
use Komposita::Splitter;
use Komposita::Transform;

our $VERSION = '0.1';

$Data::Dumper::Indent = 3;

# TODO: I don't know what file this should go into
sub tree_as_table {
	my ($tree, $indent) = @_;
	$indent ||= 0;
	my @ret;

	push @ret, "<table>";

	if (exists $tree->{match}) {
		push @ret, "<tr>";
		push @ret, "<td>" . $tree->{match} . "</td>";
		push @ret, "</tr>";

		if (1) {
			push @ret, "<tr>";
			push @ret, "<td>TRANSLATION GOES HERE</td>";
			push @ret, "</tr>";
		}

	}

	push @ret, "<tr>";

	if (defined $tree->{ptree}) {
		push @ret, "<td>";
		push @ret, tree_as_table($tree->{ptree}, $indent + 1);
		push @ret, "</td>";
	}

	if (defined $tree->{stree}) {
		push @ret, "<td>";
		push @ret, tree_as_table($tree->{stree}, $indent + 1);
		push @ret, "</td>";
	}

	push @ret, "</tr>";

	push @ret, "</table>";

	return join("\n" . ("  " x $indent), @ret);
}


get '/' => sub {
    template 'index';
};

get '/split/:q' => sub {
    my $query = lc(params->{"q"});
    die "missing parameter" unless $query;

    my $splitter = Bandwordersplitter::Translator::new_de_splitter();

	my $tree = $splitter->($query);
	$tree = Komposita::Transform::map($tree,
		sub {
			my ($node) = @_;

			return $node;
		});

	template 'result', { tree => $tree }
};

true;
