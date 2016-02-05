#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Bandwordersplitter::App;
Bandwordersplitter::App->to_app;
