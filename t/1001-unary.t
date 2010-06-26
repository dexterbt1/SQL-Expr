use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr '-all';

my $e;
my ($stmt, @bind);

dies_ok { $e = Not_; } 'undef Not_';
dies_ok { $e = Not_(Literal('id'), Literal('id')); } 'Not_ > 1 params';
dies_ok { $e = Not_(1); } 'Not_ auto-bind';
dies_ok { $e = Not_(\'id'); } 'Not_ auto-literal';

$e = Not_(Literal('id') == 2);
is "$e", 'NOT( id = 2 )';
($stmt, @bind) = $e->compile;
is $stmt, 'NOT( id = ? )';
is scalar(@bind), 1;

my @test = (
    [ Not_(undef), 'NOT( NULL )' ],
    [ Not_(Eq_(\'id', 1)), 'NOT( id = ? )', 1 ],
    [ Not_(And_(Eq_(\'id', 1), Gte_(\'x', 2))), 'NOT( ( id = ? ) AND ( x >= ? ) )', 1, 2 ],
);

foreach (@test) {
    my ($e, $stmt, @bind) = @$_;
    is $e->stmt, $stmt, $stmt;
    is_deeply [ $e->bind ], \@bind, "bind for $stmt";
}

ok 1;


__END__
