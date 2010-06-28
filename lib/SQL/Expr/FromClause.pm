package SQL::Expr::FromClause;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    if (not exists $self->{columns}) {
        $self->{columns} = [ ];
    }
    foreach my $col (@{$self->{columns}}) {
        (blessed($col) && $col->isa('SQL::Expr::ColumnElement'))
            or Carp::confess("Unknown column type encountered. Expected SQL::Expr::ColumnElement");
    }
}


# readonly accessor
sub columns {
    my ($self) = @_;
    my $c = $self->{columns} || [ ];
    return @$c;
}


sub columns_stmt {
    die "Unimplemented";
}

sub columns_bind {
    die "Unimplemented";
}


1;

__END__
