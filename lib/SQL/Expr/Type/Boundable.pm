package SQL::Expr::Type::Boundable;
use strict;
use Carp ();
use base qw/SQL::Expr::Comparable/;

sub _BUILD {
    my ($self, $val) = @_;
    $self->{boundable} = $val;
}

sub stmt { '?' }

sub bind { return ($_[0]->{boundable}) }

sub _str { $_[0]->{boundable} }

1;

__END__
