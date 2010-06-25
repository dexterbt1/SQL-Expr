package SQL::Expr::ClauseElement;
use strict;
use Carp ();

use overload 
    '""'        => '_str',
    "=="        => '_eq',
    "!="        => '_neq',
    ">="        => '_gte',
    ">"         => '_gt',
    "<="        => '_lte',
    "<"         => '_lt',
    ;

sub new {
    my $class = shift @_;
    my $self = bless({ }, $class);
    if ($class->can('_BUILD')) { $self->_BUILD(@_); }
    return $self;
}

sub compile { 
    my ($self) = @_;
    return ($self->stmt, $self->bind);
}

sub stmt { Carp::confess("Unimplemented"); }
sub bind { Carp::confess("Unimplemented"); }


sub _str { Carp::confess("Unimplemented"); }


sub _eq     { Carp::confess("Unimplemented"); }
sub _neq    { Carp::confess("Unimplemented"); }
sub _gte    { Carp::confess("Unimplemented"); }
sub _gt     { Carp::confess("Unimplemented"); }
sub _lte    { Carp::confess("Unimplemented"); }
sub _lt     { Carp::confess("Unimplemented"); }

1;

__END__

