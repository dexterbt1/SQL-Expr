package SQL::Expr::Func;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;

sub _construct_func {
    my $class = shift;
    my @args = map {
        if (not defined $_) {
            SQL::Expr::Type::Null->new;
        }
        elsif (ref($_) eq 'SCALAR') {
            SQL::Expr::Type::Literal->new($$_);
        }
        elsif (not blessed $_) {
            SQL::Expr::Type::Boundable->new($_);
        }
        else {
            $_;
        }
    } @_;
    return $class->new(@args);
}


1;

__END__
