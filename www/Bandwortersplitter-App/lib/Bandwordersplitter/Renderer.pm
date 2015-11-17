package Bandwordersplitter::Renderer;

use Bandwordersplitter::Translator;
use Dancer2;
use Data::Dumper;
use Komposita::Splitter;
use Komposita::Transform;

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

    if (exists $node->{match}) {
        push @ret, "<h3>" . leo_link($node->{match}) . "</h3>";

        if (exists $node->{en}) {
            push @ret, "<pre>" . $node->{en} . "</pre>";
        }
    }


    if (defined $node->{ptree} && defined $node->{stree}) {
    	push @ret, "<table>";

		push @ret, "<tr><td>$node->{prefix}</td><td>$node->{suffix}</td></tr>";
		push @ret, "<tr>";
        push @ret, "<td>";
        push @ret, tree_as_table($node->{ptree}, $indent + 1);
        push @ret, "</td>";

        push @ret, "<td>";
        push @ret, tree_as_table($node->{stree}, $indent + 1);
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

    my $node = $splitter->($query);
    $node = Komposita::Transform::map(
        sub {
            my ($node) = @_;
       
			return $node unless (defined $node->{match});
            
			$node->{en} = Bandwordersplitter::Translator::translate($node->{match});

            return $node;
        }, $node);

    return tree_as_table($node);
}

true;
