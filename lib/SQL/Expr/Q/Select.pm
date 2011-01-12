package SQL::Expr::Q::Select;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::FromClause/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    (defined($self->{from}) || defined($self->{columns}))
        or Carp::confess("Select expects -from OR -columns declaration");
    # check -columns
    if (defined $self->{columns}) {
        my $cols = $self->{columns};
        ( (ref($cols) eq 'ARRAY') && (scalar(@$cols) > 0) )
            or Carp::confess("Select -columns definition should be a non-empty arrayref");
        # auto coerce
        foreach my $c (@$cols) {
            (blessed($c) && ($c->isa('SQL::Expr::ClauseElement')))
                or Carp::confess("Select -columns items should be a SQL::Expr::ClauseElement");
        }
    }
    else {
        $self->{columns} = [ ];
    }
    # check -from
    if (defined $self->{from}) {
        if (ref($self->{from}) eq 'ARRAY') {
            foreach my $from_item (@{$self->{from}}) {
                (blessed($from_item) && $from_item->isa("SQL::Expr::FromClause"))
                    or Carp::confess("Select -from should be a SQL::Expr::FromClause, OR an ARRAYREF of SQL::Expr::FromClause objects");
            }
        }
        elsif (blessed($self->{from}) && $self->{from}->isa("SQL::Expr::FromClause")) {
            # good
        }
        else {
            Carp::confess("Select -from should be a SQL::Expr::FromClause, OR an ARRAYREF of SQL::Expr::FromClause objects");
        }
    }
    # check where
    if (exists $self->{where}) {
        (defined $self->{where})
            or Carp::confess("Select -where cannot be undef");
        (defined $self->{from})
            or Carp::confess("Select with -where clause expects a -from clause");
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
        elsif (defined $self->{from}) {
            if (ref($self->{from}) eq 'ARRAY') {
                @cols_stmt = map { $_->columns_stmt(@_) } @{$self->{from}};
            }
            else {
                @cols_stmt = $self->{from}->columns_stmt(@_);
            }
        }
    }
    # FROM
    my $from = $self->{from};
    my $from_clause = '';
    {
        if (defined $from) {
            if (ref($from) eq 'ARRAY') {
                $from_clause = sprintf(
                    " FROM %s",
                    join( ", ", map { $_->stmt(@_) } @$from),
                );
            }
            else {
                $from_clause = sprintf(" FROM %s", $from->stmt(@_));
            }
        }
    }
    # WHERE
    my $where_clause = '';
    {
        my $where = $self->{where};
        if (defined $where) {
            $where_clause = sprintf(" WHERE %s", $where->stmt(@_) );
        }
    }
    my $stmt = sprintf("SELECT %s%s%s",
        join(', ', @cols_stmt),
        $from_clause,
        $where_clause,
    );
    return $stmt;
}

sub bind {
    my $self = shift @_;
    my @out = ();
    # columns
    my $cols = $self->{columns};
    if (scalar @$cols > 0) {
        my @cb = map { $_->bind(@_) } @$cols;
        push @out, @cb;
    }
    # from
    if (defined $self->{from}) {
        if (ref($self->{from}) eq 'ARRAY') {
            push @out, map { $_->columns_bind(@_) } @{$self->{from}};
        }
        else {
            push @out, $self->{from}->columns_bind(@_);
        }
    }
    # where
    if (defined $self->{where}) {
        push @out, $self->{where}->bind(@_);
    }
    return @out;
}

sub _str {
    my ($self) = @_;
    return $self->stmt;
}

sub name {
    my ($self) = @_;
    return $self->stmt(@_);
}

1;

__END__
