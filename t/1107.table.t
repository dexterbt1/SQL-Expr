package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr::Table;

my $table;
my @columns;
my ($stmt, @bind);

# NO args
$table = SQL::Expr::Table->new;
isa_ok $table, 'SQL::Expr::Table';
is $table->name, undef;
@columns = $table->columns;
is scalar(@columns), 0;

# dynamically added column
$table = SQL::Expr::Table->new;
dies_ok {
    $table->add_column;
} 'undef column';
dies_ok {
    $table->add_column( 1 );
} 'invalid column';
dies_ok {
    $table->add_column( SQL::Expr::Column->new );
} 'invalid column name';
dies_ok {
    $table->add_column( SQL::Expr::Column->new( -name => undef ) );
} 'invalid column name';
lives_ok {
    $table->add_column( SQL::Expr::Column->new( -name => 'id' ) );
} 'valid column name';
@columns = $table->columns;
is scalar(@columns), 1;


# complete and minimal declaration
$table = SQL::Expr::Table->new(
    -name => 'person', 
    -columns => [
        SQL::Expr::Column->new( -name => 'id' ),
        SQL::Expr::Column->new( -name => 'name' ),
    ],
);
isa_ok $table, 'SQL::Expr::Table';
is $table->name, 'person';
@columns = $table->columns;
is scalar(@columns), 2;

# TODO: next step
# dynamic collection object for acccessing the table column by name
# AUTOLOAD?
#
# $table->c->id
# $table->c->name
#
##is_deeply $table->c



=pod

my $sel = SQL::Expr::Select->new( 
    -from => $Person->inner_join( $Address, $Person->c->id == $Address->c->person_id ),
    -where => [
        ($Person->c->name == "Dexter") | ($Person->c->id == 12)
    ],
);

$session->objects('Person')
        ->filter( Person->name == "Dexter" )
        
Music::Artist->artistid->in( 1, 2, 3 );

=cut

ok 1;
    

1;

__END__
