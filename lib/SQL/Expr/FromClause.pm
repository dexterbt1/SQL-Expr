package SQL::Expr::FromClause;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    if (exists $self->{columns}) {
        foreach my $col (@{$self->{columns}}) {
            (blessed($col) && $col->isa('SQL::Expr::ClauseElement'))
                or Carp::confess("Unknown column type encountered. Expected SQL::Expr::ClauseElement");
        }
    }
}


# readonly accessor
sub columns {
    my ($self) = @_;
    my $c = (exists $self->{columns}) ? $self->{columns} : [ ];
    return @$c;
}


sub name {
    Carp::confess("Unimplemented");
}

sub columns_stmt {
    my $self = shift @_;
    my @out = ();
    foreach my $c ($self->columns) {
        push @out, $c->stmt(@_);
    }
    return @out;
}

sub columns_bind {
    my $self = shift @_;
    my @out = ();
    foreach my $c ($self->columns) {
        push @out, $c->bind(@_);
    }
    return @out;
}


1;

__END__
