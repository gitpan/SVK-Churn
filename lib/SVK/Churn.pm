package SVK::Churn;
use Spiffy -Base;
our $VERSION = '0.01';
use IO::All;
use SVK;
use SVK::XD;
use SVK::Util qw(get_anchor catfile catdir);
use SVK::Command::Log;
use SVK::Command::Diff;
use Date::Parse;

field output => 'svk-commits-churn.png';
field quiet => 0;
field repository => '';
field chart => [], -init => q{Chart::Strip->new};

# commits / authors
field chart_type => 'commits';

sub process {
  $self->repository || die "Must set repository\n";

  $ENV{HOME} ||= catfile(@ENV{qw( HOMEDRIVE HOMEPATH )});
  my $svkpath = $ENV{SVKROOT} || catfile($ENV{HOME}, ".svk");
  my $xd = SVK::XD->new ( giantlock => "$svkpath/lock",
			  statefile => "$svkpath/config",
			  svkpath => $svkpath,
			);
  $xd->load;
  my $cmd = SVK::Command::Log->new($xd);
  my $target = $cmd->parse_arg($self->repository);
  my %authors = ();
  my @data;
  my $commit=0;

  my $append = sub {
    my ($revision,$root,$paths,$props,$sep,$output,$indent,$print_rev)=@_;
    my ($author,$date) = @{$props}{qw/svn:author svn:date/};
    my $time = str2time($date);
    if($author && !($author eq 'svm')) {
        $authors{$author}++;
#        push @data,{time=>$time,value=>scalar(keys %authors)};
        push @data,{time=>$time,value=>$commit++};
    }
  };

  SVK::Command::Log::_get_logs($target->root($xd),-1,$target->{path},0,$target->{repos}->fs->youngest_rev,1,0,$append) ;

  @data = sort {$a->{time} <=> $b->{time} } @data;
  $self->chart->add_data(\@data,{style=>'line',color=>'FF0000'});
  io($self->output)->print($self->chart->png());

  return $self;
}


__END__

=head1 NAME

  SVK::Churn - Generate SVK Statistics graph.

=head1 SYNOPSIS

  svk-churn.pl //mirror/svk

=head1 DESCRIPTION

This module helps you to understand yor svk repository developing
statistics. It'll generate a file named C<svk-commits-churn.png> under
current directory.

It's still rough and will be improved in the future.

=head1 SEE ALSO

C<SVN::Churn>

=head1 COPYRIGHT

Copyright 2005 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut

