package Quatsch::Splitter;

use 5.006;
use strict;
use warnings;

use Carp;
use Dancer2;
use Data::Dumper;
use JSON;
use List::MoreUtils qw(any all);

=head1 NAME

Quatsch::Splitter - Compound word splitter

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The heart of Splitter is the functor `new` that produces a function
of one argument, that returns a tree comprised of possible splittings 
of a supplied compound word.  Behaviour is driven by three callbacks, 
used to compute whether a substring is a valid word in the language,
and, optionally, whether a substring at the beginning or end of a
supplied string is a valid prefix or suffix.  For example, the possible
splits of the German word "Unsterblichkeit" might be

[[ "Un" , "Sterblich"], ["Keit"]],
[[ "Un" ], ["Sterblich", "Keit"]]

TODO: Come up with a more fun example than this.
    
    use Quatsch::Splitter;

    my $sp = Quatsch::Splitter->new(
        \&de_prefix_lookup, \&de_word_lookup, \&de_suffix_lookup);

    my $tree = $sp->("entschuldigung");
 
=head1 SUBROUTINES/METHODS

=head2 new(&check_suffix, &check_word, &check_suffix)
    
    Consumes three functions, all of one argument, that:
        1) Evaluates whether the argument is a valid prefix,
        2) Evaluates whether the argument is a valid word,
        3) Evaluates whether the argument is a valid suffix.
        
    In turn, produces a function that, when called with a given word,
    will produce an nary tree comprised of all possible splits.  A node in
    this tree is a four-tuple containing a prefix, suffix, and pointers
    to the child nodes.  Leaf nodes are a simple hash with a match field.
=cut

sub new(&&&) {
    croak 'Splitter::new() expects three coderefs; got <' 
            . join(',', map { ref($_) || "SCALAR" } @_) 
            . '>'
        unless (@_ == 3 && all { ref($_) eq "CODE" } @_);

    my ($check_prefix, $check_word, $check_suffix) = @_;
    my %arg_cache;

    my $valid_split = sub($$) {
        my ($ptree, $stree) = @_;
		
		# A valid split is one where both splits are dictionary words.
        my $pret = $check_word->($ptree->{slice});
		my $sret = $check_word->($stree->{slice});
			
		# A valid prefix or suffix can also be one that can be reassembled
		# into a valid word (e.g. one level of the tree need not be a
		# dictionary word)
		# TODO: something like this is important for longer words but I
		# don't think this is quite it.
		#if (!$pret) {
		#		$pret |= any {
		#		my ($sp) = $_;
		#			$check_word->($sp->{ptree}->{slice}) && $check_word->($sp->{stree}->{slice});
		#		} @{$stree->{splits}};
		#}
		#if (!$sret) {
		#	$sret |= any {
		#		my ($sp) = $_;
		#		$check_word->($sp->{ptree}->{slice}) && $check_word->($sp->{stree}->{slice});
		#	} @{$stree->{splits}};
		#}
		return $pret && $sret;
    };
    my $valid_prefix = sub($$) {
        my ($prefix, $stree) = @_;
		my $valid_tree = defined $stree->{match} || scalar(@{$stree->{splits}}) > 0;
        return $valid_tree && $check_prefix->($prefix);
    };
    my $valid_suffix = sub($$) {
        my ($ptree, $suffix) = @_;
		my $valid_tree = defined $ptree->{match} || scalar(@{$ptree->{splits}}) > 0;
        return $valid_tree && $check_suffix->($suffix);
    };


    my $fn;
    $fn = sub($) {
        my ($str) = @_;
        my $ret = {slice => $str, splits => []};

        if (exists($arg_cache{$str})) {
            return $arg_cache{$str};
        }

		if ($str eq '') {
			return $ret;
		}

		if ($check_word->($str)) {
			$ret->{match} = 1;
		}

        # Recursive case: Partition $str into a prefix and a suffix.
        # If both are valid strings, include in the set to be returned.
        for my $i (1 .. length($str) - 1) {
			my $offset = int(length($str) / 2);
			if ($i % 2 == 0) {
				$offset += int($i / 2);
			} else {
				$offset -= int($i / 2);
			}

            my $prefix = substr($str, 0, $offset);
            my $suffix = substr($str, $offset, length($str));

			my $pref_rec = $fn->($prefix);
			my $suff_rec = $fn->($suffix);

            if ($valid_split->($pref_rec,   $suff_rec) ||
                $valid_prefix->($prefix,   $suff_rec) ||
                $valid_suffix->($pref_rec, $suffix)) {

				push $ret->{splits}, {
					ptree => $fn->($prefix),
					stree => $fn->($suffix),
				};
            }
        }
               
        $arg_cache{$str} = $ret;
        return $ret;
    };

    return $fn;
}

=head2 tree_as_json(@$word_tree)
    Produces a JSON representation of the supplied tree.
=cut

sub tree_as_json($%) {
    my ($tree) = @_;
    my $j = new JSON;
    return $j->encode($tree, {utf8 => 1, pretty => 1});
}

sub _match_inc {
	my ($tree) = @_;
	defined $tree->{match} ? 1 : 0;
}
sub _valid_tree {
	my ($tree) = @_;
	my $matches = scalar(grep { _match_inc($_) } $tree->{splits});
	$matches + _match_inc($tree);
}

=head1 AUTHOR

Nathan Taylor, C<< <nbtaylor at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-komposita-splitter at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Quatsch-Splitter>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Quatsch::Splitter


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Quatsch-Splitter>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Quatsch-Splitter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Quatsch-Splitter>

=item * Search CPAN

L<http://search.cpan.org/dist/Quatsch-Splitter/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Nathan Taylor.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Quatsch::Splitter
