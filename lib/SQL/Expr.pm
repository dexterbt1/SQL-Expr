package SQL::Expr;
use strict;

our $VERSION = '0.01';

use SQL::Expr::ClauseElement;
use SQL::Expr::Comparable;

use SQL::Expr::Op;

use SQL::Expr::Type::Literal;
use SQL::Expr::Type::Null;
use SQL::Expr::Type::Boundable;
use SQL::Expr::Type::Distinct;

use SQL::Expr::Schema::Table;
use SQL::Expr::Schema::Column;
use SQL::Expr::Schema::Join;

use SQL::Expr::Q::Select;

use SQL::Expr::Func;
use SQL::Expr::Func::Aggregate;

use Sub::Exporter -setup => {
    exports => [ qw/ 
            Literal Null Boundable Distinct
            Not_ Eq_ Neq_ Gt_ Gte_ Lt_ Lte_ Like_ In_ And_ Or_
            Count_ Avg_ Min_ Max_
            Table TableAlias Column
            InnerJoin LeftOuterJoin RightOuterJoin
            Select
            /,
            ],
    groups => {
            'types'     => [ qw/ Literal Null Boundable Distinct / ],
            'operators' => [ qw/ Not_ Eq_ Neq_ Gt_ Gte_ Lt_ Lte_ Like_ In_ And_ Or_ /],
            'functions' => [ qw/ Count_ Avg_ Min_ Max_ / ],
            'schema'    => [ qw/ Table TableAlias Column / ],
            'joins'     => [ qw/ InnerJoin LeftOuterJoin RightOuterJoin / ],
            'queries'   => [ qw/ Select / ]
            },
};

# ========================================

# types
sub Literal { SQL::Expr::Type::Literal->new(@_); }
sub Null { SQL::Expr::Type::Null->new; }
sub Boundable { SQL::Expr::Type::Boundable->new(@_); }
sub Distinct { SQL::Expr::Type::Distinct->new(@_); }

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

# functions
sub Count_ { SQL::Expr::Func::_construct_func('SQL::Expr::Func::Aggregate::Count',@_); }
sub Avg_ { SQL::Expr::Func::_construct_func('SQL::Expr::Func::Aggregate::Avg',@_); }
sub Min_ { SQL::Expr::Func::_construct_func('SQL::Expr::Func::Aggregate::Min',@_); }
sub Max_ { SQL::Expr::Func::_construct_func('SQL::Expr::Func::Aggregate::Max',@_); }

# ==========================

# schema
sub Table { SQL::Expr::Schema::Table->new( -name => shift @_, -columns => shift @_ ); }
sub TableAlias { SQL::Expr::Schema::TableAlias->new( -table => shift @_, -as => shift @_ ); }
sub Column { SQL::Expr::Schema::Column->new( -name => shift @_, @_ ); }

# joins
sub InnerJoin { SQL::Expr::Schema::Join->new( -left => shift @_, -right => shift @_, -type => 'Inner', -condition => shift @_ ) }
sub LeftOuterJoin { SQL::Expr::Schema::Join->new( -left => shift @_, -right => shift @_, -type => 'LeftOuter', -condition => shift @_ ) }
sub RightOuterJoin { SQL::Expr::Schema::Join->new( -left => shift @_, -right => shift @_, -type => 'RightOuter', -condition => shift @_ ) }

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
