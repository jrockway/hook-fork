use strict;
use warnings;

use Hook::Fork qw(register_child_fork_hook
                  register_before_fork_hook
                  register_parent_fork_hook);
local $| = 1;

print "1..9\n";
print "ok 1 - starting\n";

register_before_fork_hook {
    print "ok 3 - before fork\n";
};

register_parent_fork_hook {
    print "ok 4 - in parent after fork\n";
};

register_parent_fork_hook {
    print "ok 5 - in parent after fork (still!)\n";
};

register_child_fork_hook {
    sleep 1;
    print "ok 6 - in child after fork\n";
};

register_child_fork_hook {
    print "ok 7 - in child after fork (still!)\n";
};

print "ok 2 - after registering\n";

if(my $pid = fork()){
    sleep 2;
    print "ok 8 - in real parent\n";
}
else {
    sleep 3;
    print "ok 9 - in real child\n";
}

exit 0;
