package Bandwordersplitter::Renderer;

use Bandwordersplitter::Translator;
use Dancer2;
use Data::Dumper;
use Exporter;
use Komposita::Splitter;
use Komposita::Transform;
use Text::Wrap;

our @EXPORT_OK = qw(gen_split);

our $VERSION = '0.1';

sub leo_link {
    my ($word) = @_;

    return '<a href="http://dict.leo.org/ende/index_de.html#/search=' . $word . '">'
        . $word . '</a>';
}

sub tree_as_table {
    my ($node, $indent) = @_;
    $indent ||= 0;
    my @ret;

    push @ret, '<div id="tree">';

	if (defined $node->{en}) {
		push @ret, "<h3>" . leo_link($node->{de}) . "</h3>";
	} else {
		push @ret, "<h3>$node->{de}</h3>";
	}

	if (defined $node->{en}) {
		$Text::Wrap::columns = 30;
		push @ret, "<pre>" . wrap("", "", $node->{en}) . "</pre>";
	}
	push @ret, "<h4>($node->{ok_trans}/$node->{total_trans})</h4>";

    if (defined $node->{split}) {
		my $split = $node->{split};
    	push @ret, "<table>";

		push @ret, "<tr>";
        push @ret, "<td>";
        push @ret, tree_as_table($split->{ptree}, $indent + 1);
        push @ret, "</td>";

        push @ret, "<td>";
        push @ret, tree_as_table($split->{stree}, $indent + 1);
        push @ret, "</td>";
    
		push @ret, "<tr>";
		push @ret, "</table>";
    }


    push @ret, "</div>";

    return join("\n" . ("  " x $indent), @ret);
}


sub gen_split {
    my ($query) = @_;

    return undef if $query eq '';

    my $splitter = Bandwordersplitter::Translator::new_de_splitter();

    my $result = $splitter->($query);

    $result = Komposita::Transform::map(
        \&Bandwordersplitter::Translator::create_translated_node, $result);

    return tree_as_table($result);
}

true;
