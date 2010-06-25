package SQL::Expr::Literal;
use strict;
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::Comparable/;

sub _BUILD {
    my ($self, $str) = @_;
    $self->{literal} = $str;
}

sub stmt { $_[0]->_str }

sub bind { }

sub _str { $_[0]->{literal} }

1;

__END__
