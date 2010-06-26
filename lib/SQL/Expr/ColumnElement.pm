package SQL::Expr::ColumnElement;
use strict;
use Carp ();
use SQL::Expr::Alias;
use base qw/SQL::Expr::Comparable/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    my $name = $self->{name};
    (defined($name) && length($name)>0)
        or Carp::confess("ColumnElement expects defined and valid name");
    $self->{name} = $name;
}

sub stmt {
    my ($self) = @_;
    $_[0]->{alias} || $_[0]->{name};
}

sub bind { 
}

sub _str { 
    $_[0]->{alias} || $_[0]->{name};
}

sub as {
    my ($self, $alias) = @_;
    (defined($alias) && length($alias)>0)
        or Carp::confess("ColumnElement expects defined and valid alias");
    return SQL::Expr::Alias->new( $self->{name}, $alias );
}

sub like { 
    my $self = shift @_;
    $self->_binary_op( 'SQL::Expr::Op::Like', @_ );
}

sub in {
    my $self = shift @_;
    if (scalar @_ > 0) {
        return $self->_binary_op( 
            'SQL::Expr::Op::In', 
            SQL::Expr::LiteralGroup->new(@_),
        );
    }
    return;
}


# asc()¶
# between(cleft, cright)¶           # done
# collate(collation)¶
# concat(other)¶
# contains(other, **kwargs)¶
# desc()¶
# distinct()¶
# endswith(other, **kwargs)¶
# ilike(other, escape=None)¶
# in_(other)¶                       # done
# like(other, escape=None)¶
# match(other, **kwargs)¶


1;

__END__
