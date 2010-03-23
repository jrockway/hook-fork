package Hook::Fork;
use strict;
use warnings;
use parent qw/DynaLoader/;

our $VERSION = '0.01';

__PACKAGE__->bootstrap($VERSION);

use Hook::Fork::Task;
use Guard;

my %state;

BEGIN {
    %state = (
        parent => {
            head => undef,
            tail => undef,
        },
        child => {
            head => undef,
            tail => undef,
        },
        before => {
            head => undef,
            tail => undef,
        },
    );
}

sub make_registerer {
    my ($which) = @_;
    my $state = $state{$which} || die 'wtf';

    return sub(&) {
        my $code = shift;
        my $obj = Hook::Fork::Task->new($code);

        $state->{head} = $obj if !$state->{head};
        $state->{tail}->append($obj) if $state->{tail};
        $state->{tail} = $obj;
    }
}

sub make_runner {
    my ($which) = @_;
    my $state = $state{$which} || die 'wtf';

    return sub {
        my $node = $state->{head};
        return if !$node;
        do {
            $node->run
        } while ($node = $node->{next});
        return;
    }
}

BEGIN {
    *register_parent_fork_hook = make_registerer('parent');
    *register_child_fork_hook  = make_registerer('child');
    *register_before_fork_hook = make_registerer('before');
    *run_parent_hooks = make_runner('parent');
    *run_child_hooks  = make_runner('child');
    *run_before_hooks = make_runner('before');
}

sub init {
    my $code = _init();
    if( $code != 0) {
        $! = $code;
        die "Problem hooking fork with pthread_atfork: $!";
    }
}

use Sub::Exporter -setup => {
    exports => [ map { "register_${_}_fork_hook" } keys %state ],
};

sub _get_state {
    return \%state;
}

init(); # setup the main handler

1;
__END__

=head1 NAME

Hook::Fork - automatically run code after a fork

=head1 SYNOPSIS

    use Hook::Fork qw(register_child_fork_hook);
    register_child_fork_hook {
        print "fork\n";
    };

    fork();
    # prints "fork" from the child

=head1 DESCRIPTION

Forking can often confuse modules; if a parent opens a socket and sets
come code to run at DESTROY to close it, that DESTROY will run in both
the parent in the child.  This means the child exiting can mess up the
parent, or the parent exiting can mess up the child.

This module lets you run some code at fork time, so you can setup a
new socket for the child, or something similar.

=head1 FUNCTIONS

=head2 register_child_fork_hook(&)

This registers another coderef to run in the child after fork.

=head2 register_parent_fork_hook(&)

This registers another coderef to run in the parent after fork.

=head2 register_before_fork_hook(&)

This registers another coderef to run before all forks.

=head1 DETAILS

All three functions work in the same way.

Normally, it pushes another handler onto the list of hooks

If you call it in scalar context, a guard object will be returned that
removes the hook when the guard object goes out of scope.

Otherwise, the hook lives forever.

You can register as many hooks as you like.  They run in FIFO order.

=head1 REPOSITORY

L<http://github.com/jrockway/hook-fork>

To contribute, just click "fork", commit changes with impunity, and
then send me a pull request.  Thanks in advance!

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2010 Jonathan Rockway

This module is free software.  You can redistribute it under the same
terms as perl itself.

