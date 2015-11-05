use strict;
use warnings;

use Bandwordersplitter::App;
use Test::More tests => 3;
use Plack::Test;
use HTTP::Request::Common;

my $app = Bandwordersplitter::App->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);

my $res  = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );

$res  = $test->request( GET '/split/foo' );
ok( $res->is_success, '[GET /] successful' );
