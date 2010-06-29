package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-types -joins -schema/;

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
$t2 = Table( 'user_profile', 
    [ 
        Column( 'id' ), 
        Column( 'user_id' ), 
        Column( 'bio' ),
    ]
);

# Join

dies_ok { $join = Join; } 'noparam';
dies_ok { $join = Join( 1 ); } 'invalid param';
dies_ok { $join = Join( Literal('user') ); } 'invalid param';
dies_ok { $join = Join( $t1 ); } 'requires t1,t2';

lives_ok { $join = Join( $t1, $t2 ); } 'minimal';
($stmt, @bind) = $join->compile;
is $stmt, 'user JOIN user_profile';
is scalar(@bind), 0;

lives_ok { $join = Join( $t1, $t2, Boundable(1234) ); } 'w/ condition';
($stmt, @bind) = $join->compile;
is $stmt, 'user JOIN user_profile ON ( ? )';
is scalar(@bind), 1;
is $bind[0], 1234;

lives_ok { $join = Join( $t1, $t2, $t1->c->id == $t2->c->user_id ); } 'w/ condition';
($stmt, @bind) = $join->compile;
is $stmt, 'user JOIN user_profile ON ( user.id = user_profile.user_id )';
is scalar(@bind), 0;

ok 1;


__END__

