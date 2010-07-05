package SQL::Expr::Schema::TableClause;
use strict;
use Carp ();
use base qw/SQL::Expr::FromClause/;



package SQL::Expr::Schema::Table::ColumnAccessor;
use strict;
use Carp ();
use Data::Dumper;
our $AUTOLOAD;

sub AUTOLOAD {
    my ($self) = @_;
    my $t = $self->{t};
    my ($method) = ($AUTOLOAD =~ /::(\w+)$/);
    if (exists $t->{name_to_column}->{$method}) {
        return $t->{name_to_column}->{$method};
    }
    Carp::confess("Unknown column name '$method'");
}

sub DESTROY {
}



package SQL::Expr::Schema::Table;
use strict;
use Carp ();
use Scalar::Util qw/blessed weaken/;
use base qw/SQL::Expr::Schema::TableClause/;
use SQL::Expr::Schema::Column;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    $self->{c_accessor} = bless( { t => $self }, 'SQL::Expr::Schema::Table::ColumnAccessor' );
    weaken $self->{c_accessor}->{t};
    $self->{name_to_column} = { };
    $self->_refresh_name_to_column();
}

sub _refresh_name_to_column {
    my $self = shift @_;
    my @columns = $self->columns;
    my $out = { };
    foreach my $c (@columns) {
        my $name = $c->{name};
        (not exists $self->{name_to_column}->{$name})
            or Carp::croak("Duplicate column named ".$name);
        $out->{$name} = $c;
        if ($c->can('set_parent')) {
            $c->set_parent($self);
        }
    }
    $self->{name_to_column} = $out;
}

sub stmt {
    my ($self) = @_;
    $self->name;
}

sub bind {
}

sub _str {
    my ($self) = @_;
    $self->{name};
}

# readonly accessor
sub name {
    my ($self) = @_;
    return $self->{name};    
}

sub c {
    my ($self) = @_;
    return $self->{c_accessor};
}

# mutators
sub add_column {
    my ($self, $col) = @_;
    # TODO: Review: this is fragile, "columns" is inherited from FromClause
    (blessed($col) && $col->isa("SQL::Expr::ColumnClause"))
        or Carp::confess("add_column expects a SQL::Expr::ColumnClause instance");
    # check for dup columns
    my $name = $col->{name};
    (not exists $self->{name_to_column}->{$name})
        or Carp::croak("Duplicate column named ".$name);
    push @{$self->{columns}}, $col;
    $self->_refresh_name_to_column();
}


#sub select {
#    my ($self) = @_;
#    return SQL::Expr::Q::Select->new( -from => $self, -columns => [ $self->columns ] );
#}

package SQL::Expr::Schema::TableAlias;
use strict;
use Carp ();
use Scalar::Util qw/weaken refaddr/;
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

sub stmt {
    my $self = shift @_;
    return sprintf("%s AS %s", $self->{table}->name, $self->name);
}

sub _str {
    my ($self) = @_;
    return $self->name;
}


1;

__END__
