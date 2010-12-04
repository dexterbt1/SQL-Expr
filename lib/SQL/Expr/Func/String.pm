package SQL::Expr::Func::String::Concat;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift;
    $self->SUPER::_BUILD(@_);
    $self->{elements} = \@_;
}

sub elements {
    my $self = shift;
    return $self->{elements};
}

sub stmt {
    my $self = shift;
    return join(" || ", map { $_->stmt(@_) } @{$self->elements});
}

sub bind {
    my $self = shift;
    return map { $_->bind(@_) } @{$self->elements};
}



1;

__END__
