package SQL::Expr::Schema::Join;
use strict;
use Carp ();
use Scalar::Util qw/blessed weaken/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift;
    $self->SUPER::_BUILD(@_);
    ((defined $self->{left}) 
        and (blessed $self->{left}) 
        and ($self->{left}->isa('SQL::Expr::Schema::Table'))
    ) or Carp::croak("Join requires -left object of type SQL::Expr::Schema::Table");
    ((defined $self->{right}) 
        and (blessed $self->{right}) 
        and ($self->{right}->isa('SQL::Expr::Schema::Table'))
    ) or Carp::croak("Join requires -right object of type SQL::Expr::Schema::Table");
}

sub stmt {
    my $self = shift;
    my $cond_stmt = '';
    if ($self->{condition}) {
        $cond_stmt = sprintf(" ON ( %s )", $self->{condition}->stmt(@_));
    }
    return sprintf("%s JOIN %s%s", $self->{left}->name, $self->{right}->name, $cond_stmt);
}

sub bind {
    my $self = shift;
    my @b = ();
    if ($self->{condition}) {
        push @b, $self->{condition}->bind;
    }
    return @b;
}

sub _str {
}

1;

__END__

