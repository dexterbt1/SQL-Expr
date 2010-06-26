package SQL::Expr::Op::Unary;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift @_;
    (@_ == 1)
        or Carp::confess("Unary operator expects at exactly 1 operand");
    my $a = shift @_;
    # ---------- a
    if (not defined $a) {
        $a = SQL::Expr::Null->new;
    }
    (blessed($a) && $a->isa("SQL::Expr::ClauseElement"))
        or Carp::confess("Unary operator expects SQL::Expr::ClauseElement");
    $self->{xp} = $a;
}

sub stmt {
    my ($self) = @_;
    my $xp = $self->{xp};
    my $stmt = sprintf('%s( %s )', 
        $self->op($xp),
        $xp->stmt,
    );
    return $stmt;
}

sub bind {
    my ($self) = @_;
    my @b = ();
    push @b, $self->{xp}->bind;
    return @b;
}

sub _str { 
    my ($self) = @_;
    my $xp = $self->{xp};
    return sprintf("%s( %s )", $self->op($xp), $xp); 
}

sub op { Carp::confess("Unimplemented"); }


# ===========================================

package SQL::Expr::Op::Unary::Not;
use base qw/SQL::Expr::Op::Unary/;
sub op { 'NOT' }


1;

__END__
