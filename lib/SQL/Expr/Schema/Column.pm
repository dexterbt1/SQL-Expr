package SQL::Expr::Schema::Column;
use strict;
use Carp ();
use Scalar::Util qw/weaken/;
use SQL::Expr::ColumnElement;
use base qw/SQL::Expr::ColumnClause/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    (defined $self->{name})
        or Carp::confess("Undefined Column -name");
}

sub set_parent_table {
    my $self = shift @_;
    $self->{parent_table} = shift @_;
    weaken $self->{parent_table};
}


1;

__END__
