package SQL::Expr;
use strict;
use SQL::Expr::ClauseElement;
use SQL::Expr::Comparable;
use SQL::Expr::Boundable;
use SQL::Expr::Literal;
use SQL::Expr::Null;

use Sub::Exporter -setup => {
    exports => [ qw/
        Literal 
        Null
        / ],
};

sub Literal { SQL::Expr::Literal->new(@_); }
sub Null { SQL::Expr::Null->new; }

1;

__END__
