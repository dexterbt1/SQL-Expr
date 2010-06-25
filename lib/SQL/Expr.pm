package SQL::Expr;
use strict;
use SQL::Expr::ClauseElement;
use SQL::Expr::Comparable;
use SQL::Expr::Boundable;
use SQL::Expr::Literal;
use SQL::Expr::Conjunction;
use SQL::Expr::Null;

use SQL::Expr::ColumnElement;

use Sub::Exporter -setup => {
    exports => [ qw/
        Literal 
        Null
        Not_
        And_
        Or_

        ColumnElement
        / ],
};

sub Literal { SQL::Expr::Literal->new(@_); }

sub Null { SQL::Expr::Null->new; }

# unary 
sub Not_ { SQL::Expr::Op::Unary::Not->new(@_); }

# conjuctions
sub And_ { 
    if (scalar @_ > 0) {
        return SQL::Expr::Op::Conjunction::And->new(@_);
    }
    return;
}

sub Or_ { 
    if (scalar @_ > 0) {
        return SQL::Expr::Op::Conjunction::Or->new(@_);
    }
    return;
}

# ==========================

sub ColumnElement { SQL::Expr::ColumnElement->new(@_); }


1;

__END__
