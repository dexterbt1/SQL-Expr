package SQL::Expr::Literal;
use strict;
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::Comparable/;

sub _BUILD {
    my ($self, $str) = @_;
    $self->{literal} = $str;
    # TODO: build this to be intelligent to detect numeric vs. strings?
}

sub stmt { $_[0]->_str }

sub bind { }

sub _str { $_[0]->{literal} }

# =====================================

package SQL::Expr::LiteralGroup;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my ($self, @in) = @_;
    my @out= ();
    foreach my $i (@in) {
        my $o = $i;
        if (not(blessed $i)) {
            $o = SQL::Expr::Literal->new($i);
        }
        push @out, $o;
    }
    $self->{e} = \@out;
}

sub stmt { $_[0]->_str }

sub bind { } 

sub _str { 
    my ($self) = @_;
    my $elements = $self->{e};
    my $str = sprintf(
        "( %s )", 
        join(', ', map { "$_" } @$elements),
    );
    return $str;
}


1;

__END__
