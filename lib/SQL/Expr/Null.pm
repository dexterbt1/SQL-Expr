package SQL::Expr::Null;
use strict;
use base qw/SQL::Expr::Comparable/;

sub _BUILD { }

sub stmt { 'NULL' }

sub bind { }

sub _str { 'NULL' }

1;

__END__
