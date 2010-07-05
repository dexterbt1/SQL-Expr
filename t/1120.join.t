package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use Data::Dumper;
use SQL::Expr qw/-types -joins -schema/;

my ($t1, $t2);
my ($join);
my ($a, $b);
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

dies_ok { $join = InnerJoin; } 'noparam';
dies_ok { $join = InnerJoin( 1 ); } 'invalid param';
dies_ok { $join = InnerJoin( Literal('user') ); } 'invalid param';
dies_ok { $join = InnerJoin( $t1 ); } 'requires t1,t2';

lives_ok { $join = InnerJoin( $t1, $t2 ); } 'minimal';
($stmt, @bind) = $join->compile;
is $stmt, 'user INNER JOIN user_profile';
is scalar(@bind), 0;

lives_ok { $join = InnerJoin( $t1, $t2, Boundable(1234) ); } 'w/ condition';
($stmt, @bind) = $join->compile;
is $stmt, 'user INNER JOIN user_profile ON ( ? )';
is scalar(@bind), 1;
is $bind[0], 1234;

lives_ok { $join = InnerJoin( $t1, $t2, $t1->c->id == $t2->c->user_id ); } 'w/ condition';
($stmt, @bind) = $join->compile;
is $stmt, 'user INNER JOIN user_profile ON ( user.id = user_profile.user_id )';
is scalar(@bind), 0;
is scalar($join->columns_stmt), 5;


$a = InnerJoin( $t1, $t2, $t1->c->id == $t2->c->user_id );
$join = InnerJoin( $a, $t1 );
($stmt, @bind) = $join->compile;
is $stmt, 'user INNER JOIN user_profile ON ( user.id = user_profile.user_id ) INNER JOIN user';
is scalar(@bind), 0;

# aliased
$a = LeftOuterJoin( $t1, $t2, $t1->c->id == $t2->c->user_id );
$b = TableAlias( $t1, 'user2' );
$join = RightOuterJoin( $a, $b, $t1->c->id == $b->c->id );
($stmt, @bind) = $join->compile;
is $stmt, 'user LEFT OUTER JOIN user_profile ON ( user.id = user_profile.user_id ) RIGHT OUTER JOIN user AS user2 ON ( user.id = user2.id )';
is scalar(@bind), 0;
is scalar($join->columns_stmt), 7;

# anonymous aliases
$a = TableAlias( $t1 );
$b = TableAlias( $t2 );
$join = InnerJoin( $a, $b );
($stmt, @bind) = $join->compile;
my ($alias1, $alias2) = ($stmt =~ /^user AS (\w+) INNER JOIN user_profile AS (\w+)/);
isnt $alias1, $alias2;


ok 1;


__END__

