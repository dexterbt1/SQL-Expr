package SQL::Expr::Op::Binary;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::Comparable/;

sub _BUILD {
    my ($self, $a, $b) = @_;
    (defined $a)
        or Carp::confess("Binary operand cannot be undef");
    (defined $b)
        or Carp::confess("Binary operand cannot be undef");
    $self->{a} = $a;
    $self->{b} = $b;
}

sub stmt {
    my ($self) = @_;
    my ($a, $b) = ($self->{a}, $self->{b});
    my $stmt = sprintf("%s %s %s", 
        $a->stmt,
        $self->op($a,$b),
        $b->stmt,
    );
    return $stmt;
}

sub bind {
    my ($self) = @_;
    my @b = ();
    push @b, $self->{a}->bind;
    push @b, $self->{b}->bind;
    return @b;
}

sub _str { 
    my ($self) = @_;
    my ($a, $b) = ($self->{a}, $self->{b});
    return sprintf("%s %s %s", $a, $self->op($a,$b), $b); 
}

sub op { Carp::confess("Unimplemented"); }

# ===========================================

package SQL::Expr::Op::Eq;
use base qw/SQL::Expr::Op::Binary/;
sub op { 
    my ($self, $a, $b) = @_;
    return 'IS' if ($b->isa('SQL::Expr::Type::Null'));
    return '=';
}


package SQL::Expr::Op::Neq;
use base qw/SQL::Expr::Op::Binary/;
sub op { 
    my ($self, $a, $b) = @_;
    return 'IS NOT' if ($b->isa('SQL::Expr::Type::Null'));
    return '<>';
}

package SQL::Expr::Op::Gte;
use base qw/SQL::Expr::Op::Binary/;
sub op { '>=' }

package SQL::Expr::Op::Gt;
use base qw/SQL::Expr::Op::Binary/;
sub op { '>' }

package SQL::Expr::Op::Lte;
use base qw/SQL::Expr::Op::Binary/;
sub op { '<=' }

package SQL::Expr::Op::Lt;
use base qw/SQL::Expr::Op::Binary/;
sub op { '<' }

package SQL::Expr::Op::Like;
use base qw/SQL::Expr::Op::Binary/;

sub op { return 'LIKE'; }

sub _BUILD {
    my ($self, $a, $b) = @_;
    $self->{a} = $a;
    # allow null values here
    $self->{b} = $b;
}

sub _str { 
    my ($self) = @_;
    my ($a, $b) = ($self->{a}, $self->{b});
    # TODO: further quote this, though we might need to use a DBI $dbh (quote_string?)
    if (not $b->isa('SQL::Expr::Type::Null')) { 
        $b = '"'.$b.'"';
    }
    return sprintf("%s %s %s", $a, $self->op($a,$b), $b); 
}


package SQL::Expr::Op::In;
use base qw/SQL::Expr::Op::Binary/;
use Scalar::Util qw/blessed/;
use Carp ();

sub op { return 'IN'; }

sub _BUILD {
    my $self = shift;
    (@_ > 1)
        or Carp::croak(ref($self)." requires 1 or params");
    my $a = shift;
    # ---------- a
    if (not defined $a) {
        $a = SQL::Expr::Type::Null->new;
    }
    elsif (ref($a) eq 'SCALAR') {
        $a = SQL::Expr::Type::Literal->new($$a);
    }
    elsif (not blessed $a) {
        $a = SQL::Expr::Type::Boundable->new($a);
    }
    $self->{a} = $a;
    $self->{b} = SQL::Expr::Type::LiteralGroup->new(@_);
}


1;

__END__

