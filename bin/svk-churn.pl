#!/usr/local/bin/perl -w
use SVK::Churn;
my $churn = SVK::Churn->new;
$churn->parse_arg(@ARGV);
$churn->process;

__END__

=head1 NAME

  svk-churn.pl - Generate SVK Statistics graph.

=head1 SYNOPSIS

  svk-churn.pl [options] //repository

=head1 OPTIONS

    -t        "commits" or "committers" or "loc"
    -q        quiet
    -o        output filename

=head1 SEE ALSO

L<SVK::Churn>, L<SVN::Churn>

=head1 COPYRIGHT

Copyright 2005 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut

