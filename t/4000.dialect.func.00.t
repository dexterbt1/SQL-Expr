use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-schema -functions -types/;

my @test = (
    # string
    [ 'mysql', Concat_(undef), 'CONCAT(NULL)' ],
    [ 'mysql', Concat_(1,2,3), 'CONCAT(?, ?, ?)', 1,2,3 ],
    [ 'mysql', Concat_(\'first_name', \'last_name' ), 'CONCAT(first_name, last_name)', ],
    [ 'mysql', Concat_(Column('first_name'), Column('last_name')), 'CONCAT(first_name, last_name)' ],

    [ 'SQLite', Concat_(undef), 'NULL' ],
    [ 'SQLite', Concat_(1,2,3), '? || ? || ?', 1,2,3 ],
    [ 'SQLite', Concat_(\'first_name', \'last_name' ), 'first_name || last_name', ],
    [ 'SQLite', Concat_(Column('first_name'), Column('last_name')), 'first_name || last_name' ],
);

foreach (@test) {
    my ($dialect, $e, $stmt, @bind) = @$_;
    my ($got_stmt, @got_bind) = $e->compile( -dialect => $dialect );
    is $got_stmt, $stmt, "$dialect:$stmt";
    is_deeply [ @got_bind ], \@bind, "bind for $stmt";
}
