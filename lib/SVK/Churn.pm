package SVK::Churn;
use Spiffy -Base;
our $VERSION = '0.02';
use IO::All;
use SVK;
use SVK::XD;
use SVK::Util qw(get_anchor catfile catdir);
use SVK::Command::Log;
use SVK::Command::Diff;
use Date::Parse;

field output => 'churn.png';
field quiet => 0;
field repository => '//';
field chart => [], -init => q{};

# commits / committers / loc (lines of codes)
field chart_type => 'commits';

sub paired_arguments {
    # type, quiet, output
    qw(-t -q -o);
}

sub parse_arg {
    my($args,@others) = $self->parse_arguments(@_);
    $self->repository($others[0]) if($others[0]);
    $self->quiet($args->{-q}) if($args->{-q});
    $self->chart_type($args->{-t}) if($args->{-t});
    $self->output($args->{-o}) if($args->{-o});
    return $self;
}

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
    my $method = $self->chart_type() . "_graph";
    if($self->can($method)) {
        my $chart = Chart::Strip->new(title => "Churn result of $self->{repository}",
                                      draw_data_labels => 1,
                                     );
        $self->$method($chart,$xd,$target);
        io($self->output)->print($chart->png());
    }
    return $self;
}

sub trace_svklog {
    my ($xd,$target,$callback,$data) = @_;
    SVK::Command::Log::_get_logs($target->root($xd),-1,$target->{path},0,$target->{repos}->fs->youngest_rev,1,0,$callback) ;
    @$data = sort {$a->{time} <=> $b->{time} } @$data;
    return $data;
}

sub loc_graph {
     my ($chart,$xd,$target) = @_;
     my (@ladd,@lremoved,@revs);
     my $append = sub {
         my ($revision,$root,$paths,$props,$sep,$output,$indent,$print_rev)=@_;
         my ($date,$author) = @{$props}{qw/svn:date svn:author/};
         my $time = str2time($date);
         push @revs,{time=>$time,value=>$revision}
             if $author && !($author eq 'svm');
     };
     $self->trace_svklog($xd,$target,$append,\@revs);

     my $output;
     my $svk = SVK->new(xd => $xd,output => \$output);
     for my $i (1..$#revs) {
         $svk->diff(-r => "$revs[$i-1]->{value}:$revs[$i]->{value}",$self->repository);
         my @lines = split/\n/,$output;
         my ($add,$rm)=(0,0);
         for(@lines) {
             next if /^[-+]{3,3} \S/;
             $add++ if/^\+/;
             $rm++  if/^\-/;
         }
         print STDERR "Rev $i, $add lines added ,$rm lines removed\n"
             unless $self->quiet;
         push @ladd,    {time=>$revs[$i]->{time},value=>$add};
         push @lremoved,{time=>$revs[$i]->{time},value=>$rm };
         $output = "";
     }
     $chart->{y_label} = "Lines of Codes";
     $chart->add_data(\@ladd,{style=>'line',label=>'Lines Added',color=>'00FF00'});
     $chart->add_data(\@lremoved,{style=>'line',label=>'Lines Removed',color=>'FF0000'});
     return $chart;
}

sub commits_graph {
    my ($chart,$xd,$target) = @_;
    my (@data,$commit);
    my $append = sub {
        my ($revision,$root,$paths,$props,$sep,$output,$indent,$print_rev)=@_;
        my ($date,$author) = @{$props}{qw/svn:date svn:author/};
        my $time = str2time($date);
        push @data,{time=>$time,value=>$commit++}
            if $author && !($author eq 'svm');
    };
    $self->trace_svklog($xd,$target,$append,\@data);
     $chart->{y_label} = "Number of Commits";
    $chart->add_data(\@data,{style=>'line',color=>'FF0000'});
    return $chart;
}

sub committers_graph {
    my ($chart,$xd,$target) = @_;
    my (@data,%authors);
    my $append = sub {
        my ($revision,$root,$paths,$props,$sep,$output,$indent,$print_rev)=@_;
        my ($author,$date) = @{$props}{qw/svn:author svn:date/};
        my $time = str2time($date);
        if($author && !($author eq 'svm')) {
            $authors{$author}++;
            push @data,{time=>$time,value=>scalar(keys %authors)};
        }
    };
    $self->trace_svklog($xd,$target,$append,\@data);
    $chart->{y_label} = "Number of Committers";
    $chart->add_data(\@data,{style=>'line',color=>'FF0000'});
    return $chart;
}



__END__

=head1 NAME

  SVK::Churn - Generate SVK Statistics graph.

=head1 SYNOPSIS

  #!/usr/local/bin/perl -w
  use SVK::Churn;
  my $churn = SVK::Churn->new;
  $churn->parse_arg(@ARGV);
  $churn->process;

=head1 DESCRIPTION

This module helps you to understand yor svk repository developing
statistics. It'll generate a file named C<svk-commits-churn.png> under
current directory.

It's still rough and will be improved in the future.

=head1 SEE ALSO

L<svn-churn.pl>, L<SVN::Churn>

=head1 COPYRIGHT

Copyright 2005 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut

