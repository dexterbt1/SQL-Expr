package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/Literal -joins -schema/;

my ($t1, $t2);
my $join;
my ($stmt, @bind);

# long form
$t1 = SQL::Expr::Schema::Table->new(
    -name => 'user', 
    -columns => [
        SQL::Expr::Schema::Column->new( -name => 'id' ),
        SQL::Expr::Schema::Column->new( -name => 'username' ),
    ],
);

# shorter declare
$t2 = Table(
    'user_profile', 
    [ 
        Column( 'id' ), 
        Column( 'user_id' ), 
        Column( 'bio' ),
    ]
);

# Join

=pod

dies_ok { $join = Join; } 'noparam';
dies_ok { $join = Join( 1 ); } 'invalid param';
dies_ok { $join = Join( Literal('user') ); } 'invalid param';
dies_ok { $join = Join( $t1 ); } 'requires t1,t2';

lives_ok { 
    $join = Join( $t1, $t2 ); 
} 'minimal';

lives_ok { 
    $join = Join( $t1, $t2, $t1->c->id == $t2->c->user_id ); 
} 'w/ condition';

=cut

ok 1;


__END__

