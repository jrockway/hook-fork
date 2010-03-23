use strict;
use warnings;

use Hook::Fork qw(register_child_fork_hook);
local $| = 1;

my $i = 1;
sub diag($) {
    print "#", @_, "\n";
}
sub pass($) {
    print "ok $i - $_[0]\n";
    $i++;
}

register_child_fork_hook { $i++ };

print "1..3\n";
pass 'in parent'; # test 1

my $pid = fork();

if($pid){
    diag "child is $pid";
    pass 'in parent after fork'; # test 2
    sleep 2;
}
else {
    sleep 1;
    pass 'in child'; # test 3
    exit 0;
}
