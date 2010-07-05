package SQL::Expr::Schema::Join;
use strict;
use Carp ();
use Scalar::Util qw/blessed weaken/;
use base qw/SQL::Expr::FromClause/;


sub _BUILD {
    my $self = shift;
    $self->SUPER::_BUILD(@_);
    ((defined $self->{left}) 
        and (blessed $self->{left}) 
        and ($self->{left}->isa('SQL::Expr::FromClause'))
    ) or Carp::confess("Join requires -left object of type SQL::Expr::Schema::Table");
    ((defined $self->{right}) 
        and (blessed $self->{right}) 
        and ($self->{right}->isa('SQL::Expr::FromClause'))
    ) or Carp::confess("Join requires -right object of type SQL::Expr::Schema::Table");
    if (defined $self->{type}) {
        my $t = $self->{type};
        ($t =~ /^Inner|LeftOuter|RightOuter$/)
            or Carp::confess("Join requires -type to be one of the ff.: Inner/LeftOuter/RightOuter");
    }
}

sub stmt {
    my $self = shift;
    my $cond_stmt = '';
    if ($self->{condition}) {
        $cond_stmt = sprintf(" ON ( %s )", $self->{condition}->stmt(@_));
    }
    return sprintf("%s %s %s%s", 
        $self->{left}->stmt(@_), 
        $self->_join_type_string,
        $self->{right}->stmt(@_), 
        $cond_stmt,
    );
}

sub _join_type_string {
    my ($self) = @_;
    my $type = $self->{type} || '';
    my $out;
    SWITCH: {
        ($type eq 'Inner') && do { $out = "INNER JOIN"; last SWITCH; };
        ($type eq 'LeftOuter') && do { $out = "LEFT OUTER JOIN"; last SWITCH; };
        ($type eq 'RightOuter') && do { $out = "RIGHT OUTER JOIN"; last SWITCH; };
        # default;
        $out = "INNER JOIN";
    };
    return $out;
}

sub bind {
    my $self = shift;
    my @b = ();
    if ($self->{condition}) {
        push @b, $self->{condition}->bind;
    }
    return @b;
}

sub _str {
    my $self = shift;
    return $self->stmt;
}

sub name {
    my $self = shift;
    return $self->_str;
}


sub columns_stmt {
    my $self = shift;
    my @out = ($self->{left}->columns_stmt(@_), $self->{right}->columns_stmt(@_));
    return @out;
}


sub columns_bind {
    my $self = shift;
    return;
}



1;

__END__

