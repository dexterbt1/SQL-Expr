use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-all/;

my @test = (
    # boundables
    [ Eq_(1, 2), '? = ?', 1, 2 ],
    [ Neq_(1, 2), '? <> ?', 1, 2 ],
    [ Gt_(1, 2), '? > ?', 1, 2 ],
    [ Gte_(1, 2), '? >= ?', 1, 2 ],
    [ Lt_(1, 2), '? < ?', 1, 2 ],
    [ Lte_(1, 2), '? <= ?', 1, 2 ],
    [ Like_(1, 2), '? LIKE ?', 1, 2 ],
    [ In_(1, 2), '? IN ( 2 )', 1 ],
    [ In_(1, 2, 3), '? IN ( 2, 3 )', 1 ],
    [ In_(1, 2, 3, \"id"), '? IN ( 2, 3, id )', 1 ],

    # nulls
    [ Eq_(undef, undef), 'NULL IS NULL', ],
    [ Eq_(1, undef), '? IS NULL', 1 ],
    [ Eq_(undef, 1), 'NULL = ?', 1 ],
    [ Neq_(undef, undef), 'NULL IS NOT NULL', ],
    [ Neq_(1, undef), '? IS NOT NULL', 1 ],
    [ Neq_(undef, 1), 'NULL <> ?', 1 ],

    # auto literals
    [ Eq_(\"id", 1), 'id = ?', 1 ],
    [ Neq_(\"id", 1), 'id <> ?', 1 ],
    [ Gt_(\"id", 1), 'id > ?', 1 ],
    [ Gte_(\"id", 1), 'id >= ?', 1 ],
    [ Lt_(\"id", 1), 'id < ?', 1 ],
    [ Lte_(\"id", 1), 'id <= ?', 1 ],
    [ Like_(\"id", "text%"), 'id LIKE ?', 'text%' ],

    # LHS
    [ Eq_(Literal('id'), 1), 'id = ?', 1 ],
    [ Gt_(Literal('id'), 1), 'id > ?', 1 ],
    [ Gte_(Literal('id'), 1), 'id >= ?', 1 ],
    [ Lt_(Literal('id'), 1), 'id < ?', 1 ],
    [ Lte_(Literal('id'), 1), 'id <= ?', 1 ],
    [ Like_(Literal('name'), 'John%'), 'name LIKE ?', 'John%' ],

    # RHS
    [ Eq_(1, Literal('id')), '? = id', 1 ],
    [ Gt_(1, Literal('id')), '? > id', 1 ],
    [ Gte_(1, Literal('id')), '? >= id', 1 ],
    [ Lt_(1, Literal('id')), '? < id', 1 ],
    [ Lte_(1, Literal('id')), '? <= id', 1 ],
    [ Like_("John%", Literal('name')), '? LIKE name', 'John%' ],

);

foreach (@test) {
    my ($e, $stmt, @bind) = @$_;
    is $e->stmt, $stmt, $stmt;
    is_deeply [ $e->bind ], \@bind, "bind for $stmt";
}

# =========

# 1 param in binary ops
dies_ok { Eq_(\'id') } '1-param Eq';
dies_ok { Neq_(\'id') } '1-param Neq';
dies_ok { Gt_(\'id') } '1-param Gt';
dies_ok { Gte_(\'id') } '1-param Gte';
dies_ok { Lt_(\'id') } '1-param Lt';
dies_ok { Lte_(\'id') } '1-param Lte';
dies_ok { In_(\'id') } '1-param In';

# 2 param in binary ops, lives!
lives_ok { Eq_(\'id', 1) } '2-param Eq';
lives_ok { Neq_(\'id', 1) } '2-param Neq';
lives_ok { Gt_(\'id', 1) } '2-param Gt';
lives_ok { Gte_(\'id', 1) } '2-param Gte';
lives_ok { Lt_(\'id', 1) } '2-param Lt';
lives_ok { Lte_(\'id', 1) } '2-param Lte';

# 3 param in binary ops, expected 2
dies_ok { Eq_(\'id', 1, 1) } '3-param Eq';
dies_ok { Neq_(\'id', 1, 1) } '3-param Neq';
dies_ok { Gt_(\'id', 1, 1) } '3-param Gt';
dies_ok { Gte_(\'id', 1, 1) } '3-param Gte';
dies_ok { Lt_(\'id', 1, 1) } '3-param Lt';
dies_ok { Lte_(\'id', 1, 1) } '3-param Lte';

ok 1;

__END__
