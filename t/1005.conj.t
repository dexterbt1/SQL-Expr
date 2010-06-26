use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/Literal Null Not_ And_ Or_/;

my $e;
my ($stmt, @bind);

$e = And_();
is "$e", '';

$e = And_( Literal('1') );
is "$e", '( 1 )';
($stmt, @bind) = $e->compile;
is $stmt, '( 1 )';
is scalar(@bind), 0;

$e = And_( 
    Literal('a.id') == 123, 
    Literal('a.id') == Literal('b.id'),
);
is "$e", '( a.id = 123 ) AND ( a.id = b.id )';
($stmt, @bind) = $e->compile;
is $e->stmt, '( a.id = ? ) AND ( a.id = b.id )';
is scalar(@bind), 1;

# nested
$e = And_( 
    And_( 
        And_( 
            Literal('1'), 
            Literal('2'),
        ),
    ),
);
is "$e", "( ( ( 1 ) AND ( 2 ) ) )";

# mixed and,or,not
$e = And_(
    Literal('id') != Null,
    Not_(
        Or_(
            Literal('x') > 100,
            Literal('y') <= 200, 
        ),
    ),
);
is "$e", "( id IS NOT NULL ) AND NOT( ( x > 100 ) OR ( y <= 200 ) )";
($stmt, @bind) = $e->compile;
is $e->stmt, "( id IS NOT NULL ) AND NOT( ( x > ? ) OR ( y <= ? ) )";
is scalar(@bind), 2;


# bitwise & as the AND workaround
$e = (Literal('a') < 123) & (Literal('a') != Null);

is "$e", "( a < 123 ) AND ( a IS NOT NULL )";
($stmt, @bind) = $e->compile;
is $e->stmt, "( a < ? ) AND ( a IS NOT NULL )";
is scalar(@bind), 1;


# bitwise | as the OR workaround
$e = (Literal('a') < 123) | (Literal('a') != Null);

is "$e", "( a < 123 ) OR ( a IS NOT NULL )";
($stmt, @bind) = $e->compile;
is $e->stmt, "( a < ? ) OR ( a IS NOT NULL )";
is scalar(@bind), 1;



__END__
