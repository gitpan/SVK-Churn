#!/usr/local/bin/perl -w
use SVK::Churn;
SVK::Churn->new(repository => $ARGV[0] || die("Please give me a depot-path"))->process;
