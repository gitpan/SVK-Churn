use inc::Module::Install;

name            ('SVK-Churn');
abstract        ('Generate SVK Statistics graph');
author          ('Kang-min Liu <gugod@gugod.org>');
license         ('perl');
version_from    ('lib/SVK/Churn.pm');
requires        (Spiffy=>0,
                 Chart::Strip=>0);
build_requires  ('Test::More');
install_script  ('bin/svk-churn.pl');

&WriteAll;
