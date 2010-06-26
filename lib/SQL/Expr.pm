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

        Eq_
        Neq_
        Gt_
        Gte_
        Lt_
        Lte_
        Like_

        In_ 

        And_
        Or_

        ColumnElement
        / ],
};

sub Literal { SQL::Expr::Literal->new(@_); }

sub Null { SQL::Expr::Null->new; }

# unary 
sub Not_ { 
    SQL::Expr::Op::Unary::Not->new(@_); 
}

# binary
sub Eq_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Eq', @_); }
sub Neq_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Neq', @_); }
sub Gt_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Gt', @_); }
sub Gte_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Gte', @_); }
sub Lt_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Lt', @_); }
sub Lte_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Lte', @_); }
sub Like_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Like', @_); }

sub In_ { SQL::Expr::Op::In->new(@_); }

# conjuctions
sub And_ { 
    return SQL::Expr::Op::Conjunction::And->new(@_);
}

sub Or_ { 
    return SQL::Expr::Op::Conjunction::Or->new(@_);
}

# ==========================

sub ColumnElement { 
    my $name = shift @_;
    SQL::Expr::ColumnElement->new( -name => $name ); 
}


1;

__END__
