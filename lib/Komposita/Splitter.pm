package Komposita::Splitter;

use 5.006;
use strict;
use warnings;

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
    will produce an arrayref of all possible word splits for that word.
=cut

sub new {
    my ($check_prefix, $check_word, $check_suffix) = @_;

    return sub { [] }; #TODO!!!!1!
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
