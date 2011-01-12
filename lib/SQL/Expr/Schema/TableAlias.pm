package SQL::Expr::Schema::TableAlias;
use strict;
use Carp ();
use Scalar::Util qw/weaken refaddr/;
use SQL::Expr::Schema::Table;
use base qw/SQL::Expr::Schema::Table/;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD(@_);
    ($self->{table})
        or Carp::croak("TableAlias requires a valid -table instance");
    if (not $self->{as}) {
        $self->{as} = "talias".refaddr($self);
    }
    # copy the columns from the table
    my @columns_copy = ();
    foreach my $c ($self->{table}->columns) {
        if ($c->can('clone')) {
            # Schema::Column objects are clonables, given their dependence on the parent
            my $clone = $c->clone;
            $clone->set_parent($self);
            push @columns_copy, $clone;
        }
        else {
            # otherwise, don't assume anything from column, accept as is
            push @columns_copy, $c;
        }
    }
    $self->{columns} = \@columns_copy;
    $self->_refresh_name_to_column;
    # override accessor
    $self->{c_accessor} = bless( { t => $self }, 'SQL::Expr::Schema::Table::ColumnAccessor' );
    weaken $self->{c_accessor}->{t};
}

sub add_column {
    Carp::confess("Not supported. Cannot add column to an alias."); 
}

sub c {
    my ($self) = @_;
    return $self->{c_accessor};
}

sub name {
    my ($self) = @_;
    $self->{as};
}

sub table {
    my ($self) = @_;
    return $self->{table};
}

sub stmt {
    my $self = shift @_;
    my $table = $self->table;
    # add parenthesis to non-schema fromclauses, i.e. subqueries
    if ($table->isa("SQL::Expr::FromClause") && not(ref($table) eq "SQL::Expr::Schema::Table")) {
        return sprintf("( %s ) AS %s", $self->{table}->stmt(@_), $self->name);
    }
    return sprintf("%s AS %s", $self->{table}->stmt(@_), $self->name);
}

sub _str {
    my ($self) = @_;
    return $self->name;
}

1;

__END__
