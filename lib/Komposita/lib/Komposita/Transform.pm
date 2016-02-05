package Komposita::Transform;

use 5.006;
use strict;
use warnings;

use Carp;
use Dancer2;
use Data::Dumper;
use List::MoreUtils qw(all);

=head1 NAME

Komposita::Transform - Operations on word split trees.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The Transform module transforms a tree of compound word splits,
as defined in Komposita::Splitter.

    use Komposita::Splitter;
    use Komposita::Transform;

    my $sp = Komposita::Splitter->new(
        \&de_prefix_lookup, \&de_word_lookup, \&de_suffix_lookup);

    my $orig_tree = $sp->("entschuldigung");
    my $new_tree = Komposita::Transform->map($sp, sub { ... });

=head1 SUBROUTINES/METHODS

=head2 filter(\&f, @$tree)
    Produces a split tree such that the only leafs present are
    the ones in the original where the function `f`, when supplied
    with that leaf, evaluated to a truthy value.

    `f` must consume a leaf node and produce a scalar.
=cut

sub filter {
    my ($f, $node) = @_;

    croak 'Transform::filter() expects an hashref and a sub; got <'
            . join(',', map { ref($_) || "SCALAR" } @_) . '>'
        unless (ref($node) eq 'HASH' &&
                ref($f)    eq 'CODE');

    my $ret = undef;

	if (_is_leaf($node)) {
		if ($f->($node)) {
			$ret = $node;
		}
	} else {
		my $pref = Komposita::Transform::filter->($f, $node->{ptree});
		my $suff = Komposita::Transform::filter->($f, $node->{stree});

		return undef unless (defined $pref || defined $suff);
		
		$ret->{ptree} = $pref;
		$ret->{stree} = $suff;
	}

    return $ret;
}

=head2 map(\&f, @$tree)
    Produces a split tree of the same shape as the supplied one but
    where each leaf node is transformed according to the sub `f`.

    `f` must consume a leaf node and produce a leaf node.
    TODO: is a <<= -style a -> [a] signature more useful?
=cut

sub map {
    my ($f, $n) = @_;

    croak 'Transform::map() expects a tree (hashref) and a sub; got <'
            . join(',', map { ref($_) || "SCALAR" } @_) . '>'
        unless (ref($n) eq 'HASH' &&
                ref($f) eq 'CODE');
	
	my $node = {%$n};
		
	# Do a post-order traversal so we can depend on the children having
	# had the transformation applied to them.
	my @new_nodes = map {
		{
			ptree => Komposita::Transform::map->($f, $_->{ptree}),
			stree => Komposita::Transform::map->($f, $_->{stree}), 
		}
	} @{$node->{splits}};
	
	$node->{splits} = \@new_nodes;

	return $f->($node);
}

sub _is_leaf($) {
    my ($obj) = @_;
    return (scalar($obj->{splits}) > 0) ? 1 : 0;
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

1; # End of Komposita::Transform
