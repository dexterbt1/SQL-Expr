package SQL::Expr::Op::Unary;
use strict;
use Carp ();
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my ($self, $a) = @_;
    (defined $a)
        or Carp::confess("Unary operand cannot be undef");
    $self->{xp} = $a;
}

sub stmt {
    my ($self) = @_;
    my $xp = $self->{xp};
    my $stmt = sprintf('%s ( %s )', 
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
    return sprintf("%s ( %s )", $self->op($xp), $xp); 
}

sub op { Carp::confess("Unimplemented"); }


# ===========================================

package SQL::Expr::Op::Unary::Not;
use base qw/SQL::Expr::Op::Unary/;
sub op { 
    my ($self, $a, $b) = @_;
    return 'NOT';
}


1;

__END__
