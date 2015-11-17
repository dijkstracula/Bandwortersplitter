package Bandwordersplitter::App;

use Bandwordersplitter::Renderer qw(gen_split);
use Dancer2;
use Komposita::Transform;

our $VERSION = '0.1';

get '/' => sub {
    if (defined params->{"q"}) {
        my $query = lc(params->{"q"});
        return template 'index', {
            query => $query,
            tree => Bandwordersplitter::Renderer::gen_split($query)
        };
    }

    template 'index';
};

true;
