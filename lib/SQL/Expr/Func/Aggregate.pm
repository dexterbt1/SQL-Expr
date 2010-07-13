package SQL::Expr::Func::Aggregate;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift;
    my $class = ref($self);
    (scalar @_ == 1)
        or Carp::confess("$class expects single param ClauseElement object");
    $self->{expr} = shift @_;
}

sub stmt {
    my $self = shift;
    sprintf("%s(%s)", $self->func_name, $self->{expr}->stmt(@_));
}

sub _str {
    my $self = shift;
    sprintf("%s(%s)", $self->func_name, $self->{expr}->_str);
}

sub bind {
    my $self = shift;
    return $self->{expr}->bind(@_);
}

sub func_name {
    Carp::confess("Unimplemented");
}


package SQL::Expr::Func::Aggregate::Count;
use base qw/SQL::Expr::Func::Aggregate/;
sub func_name { 'COUNT' };

package SQL::Expr::Func::Aggregate::Avg;
use base qw/SQL::Expr::Func::Aggregate/;
sub func_name { 'AVG' };

package SQL::Expr::Func::Aggregate::Min;
use base qw/SQL::Expr::Func::Aggregate/;
sub func_name { 'MIN' };

package SQL::Expr::Func::Aggregate::Max;
use base qw/SQL::Expr::Func::Aggregate/;
sub func_name { 'MAX' };

1;

__END__
