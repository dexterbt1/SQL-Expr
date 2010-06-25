use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/ColumnElement Literal/;

my $c;
my $e;
my ($stmt, @bind);

$c = ColumnElement('id');
is "$c", 'id';
($stmt, @bind) = $c->compile;
is $stmt, 'id';
is scalar(@bind), 0;

# aliased
$e = $c->as("my_id");
is "$e", 'id AS my_id';
($stmt, @bind) = $e->compile;
is $stmt, 'id AS my_id';
is scalar(@bind), 0;

# comparable
$e = $c > 12345;
is "$e", 'id > 12345';
($stmt, @bind) = $e->compile;
is $stmt, 'id > ?';
is scalar(@bind), 1;
is $bind[0], 12345;

# comparable alias
dies_ok {
    $e = $c->as('uid') > 12345;
} 'cannot compare alias';

# LIKE
$e = ColumnElement('name')->like();
is "$e", 'name LIKE NULL';
($stmt, @bind) = $e->compile;
is $stmt, 'name LIKE NULL';
is scalar(@bind), 0;

$e = ColumnElement('name')->like("John%");
is "$e", 'name LIKE "John%"';
($stmt, @bind) = $e->compile;
is $stmt, 'name LIKE ?';
is scalar(@bind), 1;
is $bind[0], 'John%';

# IN

$e = ColumnElement('name')->in();
is $e, undef;

$e = ColumnElement('id')->in( 1, 2, 3 );
is "$e", 'id IN ( 1, 2, 3 )';
($stmt, @bind) = $e->compile;
is $stmt, 'id IN ( 1, 2, 3 )';
is scalar(@bind), 0;



__END__

