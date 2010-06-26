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
    my $overloaded = shift @_;
    my $op_class = shift @_;
    if (not $overloaded) {
        (scalar @_ == 2) # assert
            or Carp::confess("$op_class expects 2 parameters");
    }
    my ($a, $b, $reverse) = @_;
    # ---------- a
    if (not defined $a) {
        $a = SQL::Expr::Null->new;
    }
    elsif (ref($a) eq 'SCALAR') {
        $a = SQL::Expr::Literal->new($$a);
    }
    elsif (not blessed $a) {
        $a = SQL::Expr::Boundable->new($a);
    }
    # ---------- b
    if (not defined $b) {
        $b = SQL::Expr::Null->new;
    }
    elsif (ref($b) eq 'SCALAR') {
        $b = SQL::Expr::Literal->new($$b);
    }
    elsif (not blessed $b) {
        $b = SQL::Expr::Boundable->new($b);
    }
    return $op_class->new( $a, $b );
}

sub _eq  { _binary_op( 1, 'SQL::Expr::Op::Eq', @_ ); }
sub _neq { _binary_op( 1, 'SQL::Expr::Op::Neq', @_ ); }
sub _gte { _binary_op( 1, 'SQL::Expr::Op::Gte', @_ ); }
sub _gt  { _binary_op( 1, 'SQL::Expr::Op::Gt', @_ ); }
sub _lte { _binary_op( 1, 'SQL::Expr::Op::Lte', @_ ); }
sub _lt  { _binary_op( 1, 'SQL::Expr::Op::Lt', @_ ); }
sub _like  { _binary_op( 1, 'SQL::Expr::Op::Like', @_ ); }
sub _in  { _binary_op( 1, 'SQL::Expr::Op::In', @_ ); }
sub _bit_and { _binary_op( 1, 'SQL::Expr::Op::Conjunction::And', @_ ); }
sub _bit_or { _binary_op( 1, 'SQL::Expr::Op::Conjunction::Or', @_ ); }

1;

__END__
