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
        Not_
        / ],
};

sub Literal { SQL::Expr::Literal->new(@_); }

sub Null { SQL::Expr::Null->new; }

# unary 
sub Not_ { SQL::Expr::Op::Unary::Not->new(@_); }

1;

__END__
