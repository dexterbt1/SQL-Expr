package SQL::Expr::ClauseElement;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use Class::Load ':all';
use YAML;

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
    my $self = shift @_;
    my (%kwargs) = @_;
    # resolve dialect-specific class
    my $self_class = ref($self);
    my $class = ref($self);
    if (defined $kwargs{dbh}) {
        if (not defined $kwargs{dialect}) {
            my $dialect = $kwargs{dbh}->get_info(17);
            $kwargs{dialect} = $dialect;
        }
    }
    if (defined $kwargs{dialect}) {
        my $dialect = $kwargs{dialect} || '';
        load_class("SQL::Expr::Dialect::${dialect}");
        $class =~ s/^SQL::Expr::/SQL::Expr::Dialect::${dialect}::/g;
    }
    my ($stmt, @bind);
    {
        if ($class->can('stmt')) {
            bless $self, $class; # rebless trickery
            $stmt = $self->stmt(@_);
            bless $self, $self_class; # restore orig
        }
        else {
            $stmt = $self->stmt(@_);
        }
        # --- bind
        if ($class->can('bind')) {
            bless $self, $class; # rebless trickery
            @bind = $self->bind(@_);
            bless $self, $self_class; # restore orig
        }
        else {
            @bind = $self->bind(@_);
        }
    }
    return ($stmt, @bind);
}


sub stmt { Carp::confess("Unimplemented"); }
sub bind { Carp::confess("Unimplemented"); }

sub _str { Carp::confess("Unimplemented"); }

1;

__END__

