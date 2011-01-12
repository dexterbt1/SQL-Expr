package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-all/;
use DBI;

my $s;
my ($t, $tp);
my ($a, $b);
my ($stmt, @bind);
my $dbh = DBI->connect("DBI:SQLite:dbname=:memory:","","",{RaiseError=>1});

dies_ok { $s = SQL::Expr::Q::Select->new; } 'missing from or column_spec';
dies_ok { $s = SQL::Expr::Q::Select->new( -from => undef ); } 'missing from or columns';
dies_ok { $s = SQL::Expr::Q::Select->new( -columns => undef ); } 'missing from or columns';

# by column definition
dies_ok { $s = SQL::Expr::Q::Select->new( -columns => [ ] ); } 'columns spec cannot be empty';

$s = SQL::Expr::Q::Select->new( -columns => [ Boundable(1) ] );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT ?';
is scalar(@bind), 1;
is $bind[0], 1;


$t = Table( 'user', 
    [   Column('id'), 
        Column('username'), 
    ],
);
$tp = Table( 'user_profile', 
    [   Column('id'), 
        Column('user_id'), 
        Column('bio'), 
    ],
);

# with from $table;
dies_ok { $s = SQL::Expr::Q::Select->new( -from => Literal(1) ); } 'from should be a FromClause subclass';
dies_ok { $s = SQL::Expr::Q::Select->new( -from => Eq_(1, 1) ); } 'from should be a FromClause subclass';

# Tables are FromClause objects, which means they have columns
$s = SQL::Expr::Q::Select->new( -from => $t );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.id, user.username FROM user';
is scalar(@bind), 0;

$s = SQL::Expr::Q::Select->new( -from => $t, -columns => [ $t->c->id, Boundable(123) ] );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.id, ? FROM user';
is scalar(@bind), 1;
is $bind[0], 123;

# with WHERE

dies_ok { $s = SQL::Expr::Q::Select->new( -from => $t, -where => undef ); } 'where is undef';
dies_ok { $s = SQL::Expr::Q::Select->new( -columns => [ Boundable(1) ], -where => Boundable(1) ); } 'where without from';

$s = SQL::Expr::Q::Select->new( -from => $t, -where => (Boundable(123)) );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.id, user.username FROM user WHERE ?';
is scalar(@bind), 1;
is $bind[0], 123;


$s = SQL::Expr::Q::Select->new( 
    -columns => [ $t->c->id, Boundable(1), Literal('NOW()') ], 
    -from => $t, 
    -where => (Boundable(123)),  
);
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.id, ?, NOW() FROM user WHERE ?';
is scalar(@bind), 2;
is $bind[0], 1;
is $bind[1], 123;

# implicit joins
$s = SQL::Expr::Q::Select->new( -from => [ $t, $tp ] );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.id, user.username, user_profile.id, user_profile.user_id, user_profile.bio FROM user, user_profile';

# aliased implicit joins
$a = TableAlias( $t, 'a' );
$b = TableAlias( $tp, 'b' );
$s = SQL::Expr::Q::Select->new( -from => [ $a, $b ] );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT a.id, a.username, b.id, b.user_id, b.bio FROM user AS a, user_profile AS b';

$a = TableAlias( $t, 'a' );
$b = TableAlias( $tp, 'b' );
$s = SQL::Expr::Q::Select->new( -from => [ $a, $b ], -where => Eq_( $a->c->id, $b->c->user_id ) );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT a.id, a.username, b.id, b.user_id, b.bio FROM user AS a, user_profile AS b WHERE a.id = b.user_id';


# ANSI joins
$s = SQL::Expr::Q::Select->new( -from => InnerJoin( $t, $tp ) );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.id, user.username, user_profile.id, user_profile.user_id, user_profile.bio FROM user INNER JOIN user_profile';

# aliased joins
$a = TableAlias( $t, 'a' );
$b = TableAlias( $tp, 'b' );
$s = SQL::Expr::Q::Select->new( 
    -from => InnerJoin( $a, $b, $a->c->id == $b->c->user_id ),
);
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT a.id, a.username, b.id, b.user_id, b.bio FROM user AS a INNER JOIN user_profile AS b ON ( a.id = b.user_id )';

# subquery via IN
$a = TableAlias( $t, 'a' );
$b = TableAlias( $tp, 'b' );
$s = SQL::Expr::Q::Select->new( 
    -from       => $b, 
    -where      => $b->c->user_id->in( 
        SQL::Expr::Q::Select->new( 
            -columns    => [ $a->c->id ],
            -from       => [ $a ],
            -where      => And_( $a->c->id >= 123 ),
        ),
    ),
);
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT b.id, b.user_id, b.bio FROM user_profile AS b WHERE b.user_id IN ( SELECT a.id FROM user AS a WHERE ( a.id >= ? ) )';
is scalar(@bind), 1;
is $bind[0], 123;

# with dbh
($stmt, @bind) = $s->compile( dbh => $dbh );
is $stmt, 'SELECT "b"."id", "b"."user_id", "b"."bio" FROM "user_profile" AS b WHERE "b"."user_id" IN ( SELECT "a"."id" FROM "user" AS a WHERE ( a.id >= ? ) )';
is scalar(@bind), 1;
is $bind[0], 123;

# subquery as derived tables
$s = SQL::Expr::Q::Select->new( 
    -columns    => [ Literal('COUNT(*)') ],
    -from       => TableAlias( SQL::Expr::Q::Select->new( -from => $t ), 'c' ),
);
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT COUNT(*) FROM ( SELECT user.id, user.username FROM user ) AS c';
is scalar(@bind), 0;

# subqueries as dependent subqueries in the columns
$s = SQL::Expr::Q::Select->new( 
    -columns    => [ 
        $t->c->username, 
        TableAlias( 
            SQL::Expr::Q::Select->new( 
                -columns => [ Literal('COUNT(id)') ], 
                -from => $tp, 
            ), 
            'count_profiles' 
        ), 
    ],
    -from       => $t,
);
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT user.username, ( SELECT COUNT(id) FROM user_profile ) AS count_profiles FROM user';
is scalar(@bind), 0;

ok 1;

__END__
