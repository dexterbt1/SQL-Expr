package SQL::Expr::ClauseElement;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;

use overload 
    '""'        => '_str',
    ;

sub new {
    my $class = shift @_;
    my $self = bless({ }, $class);
    if ($class->can('_BUILD')) { $self->_BUILD(@_); }
    return $self;
}

sub _BUILD {
    my ($self, @args) = @_;
    while (my $a = shift @args) {
        # skip references and object args
        next if (blessed $a);
        next if (ref $a);
        if ($a =~ /^-(\w+)$/) {
            my $k = $1;
            my $v = shift @args;
            $self->{$k} = $v;
        }
    }
}

sub compile { 
    my ($self) = @_;
    return ($self->stmt, $self->bind);
}

sub stmt { Carp::confess("Unimplemented"); }
sub bind { Carp::confess("Unimplemented"); }

sub _str { Carp::confess("Unimplemented"); }

1;

__END__

