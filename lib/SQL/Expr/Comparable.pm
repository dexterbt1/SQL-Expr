package SQL::Expr::Comparable;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use SQL::Expr::Op;
use base qw/SQL::Expr::ClauseElement/;

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

sub _eq { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Eq', @_ ); }
sub _gte { my $self = shift; $self->_binary_op( 'SQL::Expr::Op::Gte', @_ ); }

1;

__END__
