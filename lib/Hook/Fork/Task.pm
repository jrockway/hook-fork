package Hook::Fork::Task;
use strict;
use warnings;

# note: we are not worried about memory cycles because the root lives
# as long as the program, and any removed nodes have all references
# removed.

sub new {
    my ($class, $code) = @_;
    my $self = {};
    $self->{code} = $code;
    $self->{next} = undef;
    $self->{prev} = undef;
    return bless $self, $class;
}

sub run {
    my $self = shift;
    $self->{code}->();
}

sub remove {
    my $self = shift;
    $self->{prev}{next} = $self->{next};
    $self->{next}{prev} = $self->{prev};
    $self->{next} = undef;
    $self->{prev} = undef;
}

sub append {
    my ($self, $next) = @_;
    $self->{next} = $next;
    $next->{prev} = $self;
}

1;
