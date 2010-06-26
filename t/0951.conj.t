use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-all/;

my @test = (
    # nulls
    [ And_( undef ), '( NULL )' ],
    [ Or_( undef ), '( NULL )' ],

    # auto bindables
    [ And_( 1 ), '( ? )', 1 ],
    [ Or_( 1 ), '( ? )', 1 ],

    # auto literals
    [ And_( \'id' ), '( id )' ],
    [ Or_( \'id' ), '( id )' ],

    # a li'l more complicated expressions
    [ And_( Gt_(\'id', 1), Lt_(\'id', 23) ), '( id > ? ) AND ( id < ? )', 1, 23 ],
    [ Or_( Gt_(\'id', 1), Lt_(\'id', 23) ), '( id > ? ) OR ( id < ? )', 1, 23 ],
    
);

foreach (@test) {
    my ($e, $stmt, @bind) = @$_;
    is $e->stmt, $stmt, $stmt;
    is_deeply [ $e->bind ], \@bind, "bind for $stmt";
}

ok 1;

__END__
