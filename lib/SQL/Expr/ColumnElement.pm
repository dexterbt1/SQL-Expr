package SQL::Expr::ColumnElement;
use strict;
use Carp ();
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
    $_[0]->{name};
}

sub bind { 
}

sub _str { 
    $_[0]->{name};
}

#sub as {
#    my ($self, $alias) = @_;
#    (defined($alias) && length($alias)>0)
#        or Carp::confess("ColumnElement expects defined and valid alias");
#    $self->{alias} = $alias;
#    return $self;
#}

sub like { 
    SQL::Expr::Comparable::_binary_op( 0, 'SQL::Expr::Op::Like', @_ );
}

sub in {
    SQL::Expr::Op::In->new(@_);
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

package SQL::Expr::ColumnClause;
use strict;
use Carp ();
use base qw/SQL::Expr::ColumnElement/;




1;

__END__
