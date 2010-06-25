package SQL::Expr::Comparable;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use SQL::Expr::Op;
use base qw/SQL::Expr::ClauseElement/;

use overload
    "=="        => '_eq',
    "!="        => '_neq',
    ">="        => '_gte',
    ">"         => '_gt',
    "<="        => '_lte',
    "<"         => '_lt',
    '&'         => '_bit_and',
    '|'         => '_bit_or',
    ;

sub _binary_op { 
    my ($self, $op_class, $v, $reverse) = @_;
    my ($a, $b) = ($self, $v);
    if (not defined $b) {
        $b = SQL::Expr::Null->new;
    }
    elsif (not blessed $b) {
        $b = SQL::Expr::Boundable->new($b);
    }
    return $op_class->new( $a, $b );
}

sub _eq  { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Eq', @_ ); }
sub _neq { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Neq', @_ ); }
sub _gte { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Gte', @_ ); }
sub _gt  { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Gt', @_ ); }
sub _lte { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Lte', @_ ); }
sub _lt  { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Lt', @_ ); }
sub _bit_and { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Conjunction::And', @_ ); }
sub _bit_or { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Conjunction::Or', @_ ); }

1;

__END__
