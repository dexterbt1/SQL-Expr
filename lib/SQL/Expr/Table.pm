package SQL::Expr::TableClause;
use strict;
use Carp ();
use base qw/SQL::Expr::FromClause/;



package SQL::Expr::Table::ColumnAccessor;
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



package SQL::Expr::Table;
use strict;
use Carp ();
use Scalar::Util qw/blessed/;
use base qw/SQL::Expr::TableClause/;
use SQL::Expr::Column;

sub _BUILD {
    my $self = shift @_;
    $self->SUPER::_BUILD( @_ );
    $self->{c_accessor} = bless( { t => $self }, 'SQL::Expr::Table::ColumnAccessor' );
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
    }
    $self->{name_to_column} = $out;
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
    # this is fragile, "columns" is inherited from FromClause
    (blessed($col) && $col->isa("SQL::Expr::ColumnClause"))
        or Carp::confess("add_column expects a SQL::Expr::ColumnClause instance");
    # check for dup columns
    my $name = $col->{name};
    (not exists $self->{name_to_column}->{$name})
        or Carp::croak("Duplicate column named ".$name);
    push @{$self->{columns}}, $col;
    $self->_refresh_name_to_column();
}


1;

__END__
