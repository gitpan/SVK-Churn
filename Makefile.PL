use inc::Module::Install;

name            ('SVK-Churn');
abstract        ('Generate SVK Statistics graph');
author          ('Kang-min Liu <gugod@gugod.org>');
license         ('perl');
version_from    ('lib/SVK/Command/Churn.pm');
requires        (SVK=>0.30,
                 Chart::Strip=>0);
build_requires  ('Test::More');

&WriteAll;
