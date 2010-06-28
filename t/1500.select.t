package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-types -joins -schema -queries/;

my $s;
my $t;
my ($stmt, @bind);

dies_ok { $s = SQL::Expr::Q::Select->new; } 'missing from or column_spec';
dies_ok { $s = SQL::Expr::Q::Select->new( -from => undef ); } 'missing from or columns';
dies_ok { $s = SQL::Expr::Q::Select->new( -columns => undef ); } 'missing from or columns';

# by column definition
dies_ok { $s = SQL::Expr::Q::Select->new( -columns => [ ]); } 'columns spec cannot be empty';

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




ok 1;

__END__
