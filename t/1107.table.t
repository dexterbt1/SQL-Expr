package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr::Schema::Table;
use Scalar::Util qw/refaddr/;

my $table;
my $a;
my @columns;
my ($stmt, @bind);

# NO args
$table = SQL::Expr::Schema::Table->new;
isa_ok $table, 'SQL::Expr::Schema::Table';
is $table->name, undef;
@columns = $table->columns;
is scalar(@columns), 0;

# dynamically added column
$table = SQL::Expr::Schema::Table->new;
dies_ok {
    $table->add_column;
} 'undef column';
dies_ok {
    $table->add_column( 1 );
} 'invalid column';
dies_ok {
    $table->add_column( SQL::Expr::Schema::Column->new );
} 'invalid column name';
dies_ok {
    $table->add_column( SQL::Expr::Schema::Column->new( -name => undef ) );
} 'invalid column name';
lives_ok {
    $table->add_column( SQL::Expr::Schema::Column->new( -name => 'id' ) );
} 'valid column name';
dies_ok {
    $table->add_column( SQL::Expr::Schema::Column->new( -name => 'id' ) );
} 'dup column name';
@columns = $table->columns;
is scalar(@columns), 1;


# complete and minimal declaration
$table = SQL::Expr::Schema::Table->new(
    -name => 'person', 
    -columns => [
        SQL::Expr::Schema::Column->new( -name => 'id' ),
        SQL::Expr::Schema::Column->new( -name => 'name' ),
    ],
);
isa_ok $table, 'SQL::Expr::Schema::Table';
is $table->name, 'person';
@columns = $table->columns;
is scalar(@columns), 2;

# column name accessors
dies_ok {
    isa_ok $table->c->yay, 'SQL::Expr::Schema::Column';
} 'unknown column accessed via colaccessor';
isa_ok $table->c->id, 'SQL::Expr::Schema::Column';
is $table->c->id->{name}, 'id';
isa_ok $table->c->name, 'SQL::Expr::Schema::Column';
is $table->c->name->{name}, 'name';

# individual column stmt,bind
($stmt,@bind) = $table->c->id->compile;
is $stmt, 'person.id';
is scalar(@bind), 0;

($stmt,@bind) = $table->c->name->compile;
is $stmt, 'person.name';
is scalar(@bind), 0;

(@columns) = $table->columns_stmt;
is $columns[0], 'person.id';
is $columns[1], 'person.name';


# aliased
$a = SQL::Expr::Schema::TableAlias->new( -table => $table, -as => 'x' );
is "$a", 'x';
($stmt, @bind) = $a->compile;
is $stmt, 'person AS x';
(@columns) = $a->columns_stmt;
is $columns[0], 'x.id';
is $columns[1], 'x.name';
#is $a->c->id->stmt, 'x.id';
#is $a->c->name->stmt, 'x.name';




=pod

my $sel = SQL::Expr::Select->new( 
    -from => $Person->inner_join( $Address, $Person->c->id == $Address->c->person_id ),
    -where => [
        ($Person->c->name == "Dexter") | ($Person->c->id == 12)
    ],
);

$session->query('Person')
        ->filter( Person->name == "Dexter" )

=cut

ok 1;
    

1;

__END__
