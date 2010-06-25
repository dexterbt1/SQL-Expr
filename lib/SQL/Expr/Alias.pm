package SQL::Expr::Alias;
use strict;
use Carp ();
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my ($self, $name, $alias) = @_;
    (defined($name) && length($name)>0)
        or Carp::confess("Alias expects defined and valid name");
    (defined($alias) && length($alias)>0)
        or Carp::confess("Alias expects defined and valid alias");
    $self->{name} = $name;
    $self->{alias} = $alias;
}

sub stmt {
    my ($self) = @_;
    return sprintf("%s AS %s", $self->{name}, $self->{alias});
}

sub bind { 
}

sub _str { 
    my ($self) = @_;
    sprintf("%s AS %s", $self->{name}, $self->{alias});
}

1;

__END__
