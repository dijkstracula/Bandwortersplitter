use strict;
use warnings;

use Bandwordersplitter::App;
use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;

my $app = Bandwordersplitter::App->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);

my $res  = $test->request( GET '/split' );
ok( $res->is_success, '[GET /split] successful' );
