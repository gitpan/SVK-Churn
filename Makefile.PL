use inc::Module::Install;

all_from    'lib/SVK/Command/Churn.pm';
name        'SVK-Churn';
abstract    'Generate SVK Statistics graph.';

requires 
	SVK=>0.30,
	IO::All => 0,
	Chart::Strip=>0
;

build_requires 'Test::More';

WriteAll;

