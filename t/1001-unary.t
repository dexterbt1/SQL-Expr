use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/Literal Null Not_ /;

my $e;
my ($stmt, @bind);

dies_ok { $e = Not_; } 'undef Not_';
dies_ok { $e = Not_(undef); } 'undef Not_';

$e = Not_(Literal('id') == 2);
is "$e", 'NOT( id = 2 )';
($stmt, @bind) = $e->compile;
is $stmt, 'NOT( id = ? )';
is scalar(@bind), 1;



__END__
