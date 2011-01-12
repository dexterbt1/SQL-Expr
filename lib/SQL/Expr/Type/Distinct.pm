package SQL::Expr::Type::Distinct;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift;
    $self->SUPER::_BUILD(@_);
    (scalar(@_) == 1)
        or Carp::confess("Distinct expects a single argument express");
    my $a = shift @_;
    if (not defined $a) {
        $a = SQL::Expr::Type::Null->new;
    }
    elsif (ref($a) eq 'SCALAR') {
        $a = SQL::Expr::Type::Literal->new($$a);
    }
    elsif (not blessed $a) {
        $a = SQL::Expr::Type::Boundable->new($a);
    }
    $self->{expr} = $a;
}

sub stmt {
    my $self = shift;
    sprintf("DISTINCT %s", $self->{expr}->stmt(@_));
}

sub bind {
    my $self = shift;
    return $self->{expr}->bind(@_);
}

sub _str { 
    my $self = shift;
    sprintf("DISTINCT %s", $self->{expr}->stmt(@_));
}


1;

__END__
