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
    [ 
        Column( 'id' ), 
        Column( 'username' ), 
    ]
);

# select tables;

$s = SQL::Expr::Q::Select->new( -from => $t );
($stmt, @bind) = $s->compile;
is $stmt, 'SELECT * FROM user';
is scalar(@bind), 0;

ok 1;

__END__
