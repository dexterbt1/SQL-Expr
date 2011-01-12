use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use Scalar::Util qw/refaddr/;
use SQL::Expr '-all';
use DBI; # test w/ SQLite

my $c;
my $e;
my ($stmt, @bind);

$c = Column('id');
is "$c", 'id';
($stmt, @bind) = $c->compile;
is $stmt, 'id';
is scalar(@bind), 0;

# identifier
my $dbh = DBI->connect("DBI:SQLite:dbname=:memory:","","",{RaiseError=>1});
($stmt, @bind) = $c->compile( dbh => $dbh );
is $stmt, '"id"';
is scalar(@bind), 0;


# schema info
is $c->{name}, 'id';
is $c->{parent_table}, undef;

# FIXME: add more test against aliases, esp on the ref to the column

# comparable
$e = $c > 12345;
is "$e", 'id > 12345';
($stmt, @bind) = $e->compile;
is $stmt, 'id > ?';
is scalar(@bind), 1;
is $bind[0], 12345;

# LIKE
dies_ok {
    $e = Column('name')->like();
} 'col->like()';
$e = Column('name')->like(undef);
is "$e", 'name LIKE NULL';
($stmt, @bind) = $e->compile;
is $stmt, 'name LIKE NULL';
is scalar(@bind), 0;

$e = Column('name')->like("John%");
is "$e", 'name LIKE "John%"';
($stmt, @bind) = $e->compile;
is $stmt, 'name LIKE ?';
is scalar(@bind), 1;
is $bind[0], 'John%';

($stmt, @bind) = $e->compile( dbh => $dbh );
is $stmt, '"name" LIKE ?';
is scalar(@bind), 1;
is $bind[0], 'John%';

# IN

dies_ok {
    $e = Column('name')->in();
} 'col->in()';

$e = Column('id')->in(undef);
is "$e", 'id IN ( NULL )';
($stmt, @bind) = $e->compile;
is $stmt, 'id IN ( NULL )';
is scalar(@bind), 0;

$e = Column('id')->in( 1, 2, 3 );
is "$e", 'id IN ( 1, 2, 3 )';
($stmt, @bind) = $e->compile;
is $stmt, 'id IN ( 1, 2, 3 )';
is scalar(@bind), 0;



__END__

