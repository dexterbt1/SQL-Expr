package SQL::Expr::Dialect::mysql::Func::String::Concat;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::Func::String::Concat/;

sub stmt {
    my $self = shift;
    return sprintf("CONCAT(%s)", 
        join(", ", map { $_->stmt(@_) } @{$self->elements}),
    );
}

sub bind {
    my $self = shift;
    return map { $_->bind(@_) } @{$self->elements};
}



1;

__END__
