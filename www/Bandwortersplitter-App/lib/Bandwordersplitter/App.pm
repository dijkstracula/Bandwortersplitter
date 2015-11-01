package Bandwordersplitter::App;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/split' => sub {
    my $query = params->{"q"};
    die "missing parameter" unless $query;
};

true;
