package SQL::Expr::ColumnClause;
use strict;
use Carp ();
use base qw/SQL::Expr::ColumnElement/;


package SQL::Expr::Column;
use strict;
use Carp ();
use base qw/SQL::Expr::ColumnClause/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    (defined $self->{name})
        or Carp::confess("Undefined Column -name");
}


1;

__END__
