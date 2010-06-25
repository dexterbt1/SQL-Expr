package main;
use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/ColumnElement/;

my ($stmt, @bind);

=pod

my $Person = Table('person', ['id', 'name']);
my $Address = Table('address', ['id', 'city', 'person_id']);

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
