use strict;
use warnings;
use Test::More;
use Hook::Fork::Task;

my @result;

my $a = Hook::Fork::Task->new( sub { push @result, 1 } );
my $b = Hook::Fork::Task->new( sub { push @result, 2 } );
my $c = Hook::Fork::Task->new( sub { push @result, 3 } );

$a->append($b);
$b->append($c);

my $node = $a;
do {
    $node->run;
} while ($node = $node->{next});

is_deeply \@result, [1,2,3], 'code ran in right order';

@result = ();

$b->remove;

$node = $a;
do {
    $node->run;
} while ($node = $node->{next});


is_deeply \@result, [1,3], 'remove works';

ok !defined $b->{next}, 'b cleaned up ok';
ok !defined $b->{prev}, 'b cleaned up ok';

done_testing;
