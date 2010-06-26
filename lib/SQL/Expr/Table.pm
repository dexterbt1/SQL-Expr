package SQL::Expr::TableClause;
use strict;
use Carp ();
use base qw/SQL::Expr::FromClause/;




package SQL::Expr::Table;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::TableClause/;
use SQL::Expr::Column;

# readonly accessor
sub name {
    my ($self) = @_;
    return $self->{name};    
}

# mutators
sub add_column {
    my ($self, $col) = @_;
    (blessed($col) && $col->isa("SQL::Expr::ColumnClause"))
        or Carp::confess("add_column expects a SQL::Expr::ColumnClause instance");
    push @{$self->{columns}}, $col;
}

1;

__END__
