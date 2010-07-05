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

sub clone {
    my ($self) = @_;
    return bless( { %$self }, ref($self) );
}

sub set_parent {
    my ($self, $parent) = @_;
    $self->{parent} = $parent;   
}

sub name {
    my $self = shift @_;
    return $self->{name};
}

sub stmt {
    my $self = shift @_;
    if (defined $self->{parent}) {
        return sprintf("%s.%s", $self->{parent}->name, $self->name);
    }
    $self->name;
}

sub _str {
    my $self = shift @_;
    return $self->name;
}




1;

__END__
