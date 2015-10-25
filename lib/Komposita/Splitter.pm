package Komposita::Splitter;

use 5.006;
use strict;
use warnings;

use Carp;
use Data::Dumper;
use JSON;
use List::MoreUtils qw(all);

=head1 NAME

Komposita::Splitter - Compound word splitter

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The Splitter module produces a list of list of words, comprised of 
possible splittings of a supplied compound word.  Behaviour is
driven by three callbacks, used to compute whether a substring is
a valid word in the language, and, optionally, whether a substring
at the beginning or end of a supplied string is a valid prefix or 
suffix.  For example, a possible split of the German word 
"Unsterblichkeit" might be

# prefix                   suffix
[[ "Un" ], ["Sterblich"], ["Keit"]]

TODO: Come up with a more fun example than this.

    use Komposita::Splitter;

    my $foo = Komposita::Splitter->new();
    ...

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

    my $valid_split = sub($$) {
        my ($prefix, $suffix) = @_;
        return $check_word->($prefix) && $check_word->($suffix);
    };
    my $valid_prefix = sub($$) {
        my ($prefix, $stree) = @_;
        return (scalar @$stree > 0) && $check_prefix->($prefix);
    };
    my $valid_suffix = sub($$) {
        my ($ptree, $suffix) = @_;
        return (scalar @$ptree > 0) && $check_suffix->($suffix);
    };


    my $fn;
    $fn = __internal_memoize( sub($) {
        my ($str) = @_;
        my $ret = [];

        # Base case: The input string is empty.
        if ($str eq '') {
            return $ret;
        }

        # If the supplied word is present in the dictionary,
        # add a leaf node.
        if ($check_word->($str)) {
            push @$ret, {
                match => $str,
            };
        }

        # Recursive case: Partition $str into a prefix and a suffix.
        for my $i (1 .. length($str) - 1) {
            my $prefix = substr($str, 0, $i);
            my $suffix = substr($str, $i, length($str));
  

            # TODO: Remove redundant recursive calls or add a layer
            # of memoization.
            if ($valid_split->($prefix, $suffix) or
                ($valid_prefix->($prefix, $fn->($suffix))) or
                ($valid_suffix->($fn->($prefix), $suffix))) {

                push @$ret, {
                    prefix => $prefix,
                    suffix => $suffix,
                    ptree => $fn->($prefix),
                    stree => $fn->($suffix)
                };

            }
        }
                
        return $ret;
    });

    return $fn;
}

=head2 tree_as_json(@$word_tree)
    Produces a JSON representation of the supplied tree.
=cut

sub tree_as_json($@) {
    my ($tree) = @_;
    my $j = new JSON;
    Test::More::diag(Dumper($tree));
    return $j->encode($tree, {utf8 => 1, pretty => 1});
}

# The built-in memoizer unfortunately has no way to not install
# the memoized function in the symbol table, so roll our own
# dumb little one here.  (TODO: ask @hachi whether or not this
# is actually true!)
sub __internal_memoize(&) {
    my ($fun) = @_;
    my %cache;

    my $trampoline = sub($) {
        my ($arg) = @_;
        $cache{$arg} = $fun->($arg) unless exists $cache{$arg};
        return $cache{$arg};
    };

    return $trampoline;
}

=head1 AUTHOR

Nathan Taylor, C<< <nbtaylor at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-komposita-splitter at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Komposita-Splitter>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Komposita::Splitter


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Komposita-Splitter>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Komposita-Splitter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Komposita-Splitter>

=item * Search CPAN

L<http://search.cpan.org/dist/Komposita-Splitter/>

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

1; # End of Komposita::Splitter
