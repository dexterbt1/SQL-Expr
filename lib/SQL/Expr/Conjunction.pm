package SQL::Expr::Op::Conjunction;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my ($self, @clauses) = @_;
    $self->{c} = [ ];
    foreach my $c (@clauses) {
        if (not defined $c) {
            $c = SQL::Expr::Null->new;
        }
        elsif (ref($c) eq 'SCALAR') {
            $c = SQL::Expr::Literal->new($$c);
        }
        elsif (not blessed $c) {
            $c = SQL::Expr::Boundable->new($c);
        }
        push @{$self->{c}}, $c;
    }
}

sub stmt {
    my ($self) = @_;
    my $c = $self->{c};
    my $str = join(
        sprintf(' %s ', $self->op), 
        map { 
            ($_->isa('SQL::Expr::Op::Unary')) 
                ? sprintf("%s", $_->stmt) 
                : sprintf("( %s )", $_->stmt) 
        } @$c
    );
    return $str;
}

sub bind {
    my ($self) = @_;
    my $c = $self->{c};
    my @b = map { $_->bind } @$c;
    return @b;
}

sub _str { 
    my ($self) = @_;
    my $c = $self->{c};
    my $str = join(
        sprintf(' %s ', $self->op), 
        map { 
            ($_->isa('SQL::Expr::Op::Unary')) 
                ? sprintf("%s", $_) 
                : sprintf("( %s )", $_) 
        } @$c
    );
    return $str;
}

sub op {
    Carp::confess("Unimplemented");
}


# ===========================================


package SQL::Expr::Op::Conjunction::And;
use Carp ();
use base qw/SQL::Expr::Op::Conjunction/;

sub op { 'AND' }


package SQL::Expr::Op::Conjunction::Or;
use Carp ();
use base qw/SQL::Expr::Op::Conjunction/;

sub op { 'OR' }

1;

__END__
