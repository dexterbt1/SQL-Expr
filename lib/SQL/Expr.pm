package SQL::Expr;
use strict;

our $VERSION = 0.01;

use SQL::Expr::ClauseElement;
use SQL::Expr::Comparable;

use SQL::Expr::Op;

use SQL::Expr::Type::Literal;
use SQL::Expr::Type::Null;
use SQL::Expr::Type::Boundable;

use SQL::Expr::Schema::Table;
use SQL::Expr::Schema::Column;
use SQL::Expr::Schema::Join;

use SQL::Expr::Q::Select;

use Sub::Exporter -setup => {
    exports => [ qw/ 
            Literal Null Boundable
            Not_ Eq_ Neq_ Gt_ Gte_ Lt_ Lte_ Like_ In_ And_ Or_
            Table Column
            Join
            Select
            /,
            ],
    groups => {
            'types'     => [ qw/ Literal Null Boundable / ],
            'operators' => [ qw/ Not_ Eq_ Neq_ Gt_ Gte_ Lt_ Lte_ Like_ In_ And_ Or_ /],
            'schema'    => [ qw/ Table Column / ],
            'joins'     => [ qw/ Join / ],
            'queries'   => [ qw/ Select / ]
            },
};


# ========================================

# types
sub Literal { SQL::Expr::Type::Literal->new(@_); }
sub Null { SQL::Expr::Type::Null->new; }
sub Boundable { SQL::Expr::Type::Boundable->new(@_); }

# unary ops
sub Not_ { SQL::Expr::Op::Unary::Not->new(@_); }

# binary ops
sub Eq_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Eq', @_); }
sub Neq_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Neq', @_); }
sub Gt_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Gt', @_); }
sub Gte_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Gte', @_); }
sub Lt_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Lt', @_); }
sub Lte_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Lte', @_); }
sub Like_ { SQL::Expr::Comparable::_binary_op(0, 'SQL::Expr::Op::Like', @_); }

# special ops
sub In_ { SQL::Expr::Op::In->new(@_); }

# conjuctions
sub And_ { SQL::Expr::Op::Conjunction::And->new(@_); }
sub Or_ { SQL::Expr::Op::Conjunction::Or->new(@_); }

# ==========================

# schema
sub Table { SQL::Expr::Schema::Table->new( -name => shift @_, -columns => shift @_ ); }
sub Column { SQL::Expr::Schema::Column->new( -name => shift @_, @_ ); }

# joins
sub Join { SQL::Expr::Schema::Join->new( -left => shift @_, -right => shift @_, -condition => @_ ) }

# ==========================

# queries
sub Select { 
    my $s = SQL::Expr::Q::Select->new( -from => shift @_ );
}

1;

__END__

=head1 NAME

SQL::Expr - object-oriented SQL abstraction and generation toolkit

=cut
