use inc::Module::Install;
use strict;

name 'Hook-Fork';
all_from 'lib/Hook/Fork.pm';
repository 'http://github.com/jrockway/hook-fork';

requires 'Sub::Exporter';
requires 'Guard';

test_requires 'Test::More';
cc_lib_links 'pthread';

WriteAll;
