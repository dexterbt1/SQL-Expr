use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/Literal Null/;

my $e;
my ($stmt, @bind);

$e = Literal('id');
is "$e", 'id';
($stmt, @bind) = $e->compile;
is $stmt, 'id';
is scalar(@bind), 0;

$e = (Literal('id') == 2);
isa_ok $e, 'SQL::Expr::Op::Binary';
is "$e", 'id = 2';
($stmt, @bind) = $e->compile;
is $stmt, 'id = ?';
is scalar(@bind), 1;
is $bind[0], 2; 

$e = (Literal('id') == Literal('x.pid'));
isa_ok $e, 'SQL::Expr::Op::Binary';
is "$e", 'id = x.pid';
($stmt, @bind) = $e->compile;
is $stmt, 'id = x.pid';
is scalar(@bind), 0;

$e = (8 == Literal('id'));
isa_ok $e, 'SQL::Expr::Op::Binary';
is "$e", 'id = 8';

# NULL
$e = (Literal('id') == undef);
is "$e", 'id IS NULL';
($stmt, @bind) = $e->compile;
is $stmt, 'id IS NULL';
is scalar(@bind), 0;

$e = (Literal('id') == Null()); # readable
is "$e", 'id IS NULL';

# >=
$e = (Literal('id') >= 123);
is "$e", 'id >= 123';
($stmt, @bind) = $e->compile;
is $stmt, 'id >= ?';
is scalar(@bind), 1;
is $bind[0], 123;

    
__END__
