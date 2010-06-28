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

sub stmt {
    my $self = shift @_;
    $self->_str;
}

sub _str {
    my $self = shift @_;
    if (defined $self->{parent_table}) {
        return sprintf("%s.%s", $self->{parent_table}->{name}, $self->{name});
    }
    return $self->{name};
}




1;

__END__
