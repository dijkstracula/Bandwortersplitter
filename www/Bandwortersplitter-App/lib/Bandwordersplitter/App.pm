package Bandwordersplitter::App;

use Bandwordersplitter::Translator;
use Dancer2;
use Data::Dumper;
use Komposita::Splitter;
use Komposita::Transform;

our $VERSION = '0.1';

$Data::Dumper::Indent = 3;

sub leo_link {
    my ($word) = @_;

    return '<a href="http://dict.leo.org/ende/index_de.html#/search=' . $word . '">'
        . $word . '</a>';
}
# TODO: I don't know what file this should go into
sub tree_as_table {
    my ($node, $indent) = @_;
    $indent ||= 0;
    my @ret;

    push @ret, '<div id="tree">';

    if (exists $node->{match}) {
        push @ret, "<p>" . leo_link($node->{match}) . "</p>";

        if (exists $node->{en}) {
            push @ret, "<pre>" . $node->{en} . "</pre>";
        }
    }


    if (defined $node->{ptree} && defined $node->{stree}) {
    	push @ret, "<table>";
        push @ret, "<td>";
        push @ret, tree_as_table($node->{ptree}, $indent + 1);
        push @ret, "</td>";

        push @ret, "<td>";
        push @ret, tree_as_table($node->{stree}, $indent + 1);
        push @ret, "</td>";
    
		push @ret, "</table>";
    }


    push @ret, "</div>";

    return join("\n" . ("  " x $indent), @ret);
}


sub gen_split {
    my ($query) = @_;

    debug "Query: " . $query;

    return undef if $query eq '';

    my $splitter = Bandwordersplitter::Translator::new_de_splitter();

    my $node = $splitter->($query);
    $node = Komposita::Transform::map(
        sub {
            my ($node) = @_;
        
            if (defined $node->{match}) {
                $node->{en} = Bandwordersplitter::Translator::translate($node->{match});
            }
            return $node;
        }, $node);

    return tree_as_table($node);
}

get '/' => sub {
    if (defined params->{"q"}) {
        my $query = lc(params->{"q"});
        return template 'index', {
            query => $query,
            tree => gen_split($query)
        };
    }

    template 'index';
};

true;
