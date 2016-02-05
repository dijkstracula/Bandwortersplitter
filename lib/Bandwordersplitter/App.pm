package Bandwordersplitter::App;

use Dancer2;
use Quatsch::Transform;

use Bandwordersplitter::Renderer;

our $VERSION = '0.1';

get '/' => sub {
	redirect "/split";
};

get '/split' => sub {
        
    push_header("Surrogate-Key" => "Bandwortersplitter");

    if (defined params->{"q"}) {
        my $query = lc(params->{"q"});

		if (length($query) > 100) {
			return send_error("Query too long");
		}

		# TODO: in VCL, we should do this as well to improve
		# hit rate
		$query =~ s/\s//g;
		if ($query !~ /^[[:alpha:]]*$/) {
			return send_error("Non-alphabetic characters");
		}

        return template 'split', {
            query => $query,
            tree => Bandwordersplitter::Renderer::gen_split($query)
        };
    }

    template 'split';
};

true;
