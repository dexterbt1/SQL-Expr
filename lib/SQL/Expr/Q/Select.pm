package SQL::Expr::Q::Select;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::ClauseElement/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    (defined($self->{from}) || defined($self->{columns}))
        or Carp::croak("Select expects -from OR -columns declaration");
    if (defined $self->{columns}) {
        my $cols = $self->{columns};
        ( (ref($cols) eq 'ARRAY') && (scalar(@$cols) > 0) )
            or Carp::croak("Select -columns definition should be a non-empty arrayref");
        # auto coerce
        foreach my $c (@$cols) {
            (blessed($c) && ($c->isa('SQL::Expr::ClauseElement')))
                or Carp::croak("Select -columns items should be a SQL::Expr::ClauseElement");
        }
    }
    else {
        $self->{columns} = [ ];
    }
}

sub stmt {
    my $self = shift @_;
    # columns
    my $cols = $self->{columns};
    my @cols_stmt = ();
    {
        if (scalar @$cols > 0) {
            @cols_stmt = map { $_->stmt(@_) } @$cols;
        }
        else {
            @cols_stmt = ('*');  # default
        }
    }
    # FROM
    my $from = $self->{from};
    my $from_clause = '';
    {
        if (defined $from) {
            $from_clause = sprintf(" FROM %s",$from->stmt(@_));
        }
    }
    my $stmt = sprintf("SELECT %s%s",
        join(', ', @cols_stmt),
        $from_clause,
    );
    return $stmt;
}

sub bind {
    my $self = shift @_;
    my $cols = $self->{columns};
    my @out = ();
    {
        if (scalar @$cols > 0) {
            my @cb = map { $_->bind(@_) } @$cols;
            push @out, @cb;
        }
    }
    return @out;
}

1;

__END__
