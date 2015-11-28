package Bandwordersplitter::App;

use Dancer2;
use Komposita::Transform;

use Bandwordersplitter::Renderer;

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
