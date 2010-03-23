use strict;
use warnings;

use Hook::Fork qw(register_child_fork_hook
                  register_before_fork_hook
                  register_parent_fork_hook);
local $| = 1;

print "1..7\n";
print "ok 1 - starting\n";

# do some insane "editing" of the before fork hook
my @befores;
for(1..100){
    push @befores, register_before_fork_hook {
        die 'OH NOES';
    };
}
$befores[40] = 0;
$befores[0] = 0;
$befores[-1] = 0;

register_before_fork_hook {
    print "ok 3 - before fork\n";
};

@befores = ();

register_parent_fork_hook {
    print "ok 4 - in parent after fork\n";
};

my $ignore_parent = register_parent_fork_hook {
    die 'this should have been ignored';
};

my $ignore_child = register_child_fork_hook {
    die 'this should have been ignored';
};

register_child_fork_hook {
    sleep 1;
    print "ok 5 - in child after fork\n";
};

print "ok 2 - after registering\n";

undef $ignore_parent;
undef $ignore_child;

if(my $pid = fork()){
    sleep 2;
    print "ok 6 - in real parent\n";
}
else {
    sleep 3;
    print "ok 7 - in real child\n";
}

exit 0;
