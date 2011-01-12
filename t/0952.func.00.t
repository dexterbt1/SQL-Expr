use strict;
use Test::More qw/no_plan/;
use Test::Exception;
use SQL::Expr qw/-schema -functions -types/;

my @test = (
    # aggregate
    [ Distinct(undef), 'DISTINCT NULL' ],
    [ Distinct(Null), 'DISTINCT NULL' ],
    [ Distinct(1), 'DISTINCT ?', 1 ],

    [ Count_(undef), 'COUNT(NULL)' ],
    [ Count_('id'), 'COUNT(?)', 'id' ],
    [ Count_(\'id'), 'COUNT(id)', ],
    [ Count_(Column('id')), 'COUNT(id)' ],
    [ Count_(Distinct(1)), 'COUNT(DISTINCT ?)', 1 ],
    [ Count_(Distinct(Column('id'))), 'COUNT(DISTINCT id)' ],
    [ Count_(Distinct(Boundable(1) == Boundable(2))), 'COUNT(DISTINCT ? = ?)', 1, 2 ],
    [ Count_(Distinct(Boundable(1) == Boundable(2)))->as('hello'), 'COUNT(DISTINCT ? = ?) AS hello', 1, 2 ],
    [ Count_(\'id')->as('count_id'), 'COUNT(id) AS count_id' ],

    [ Avg_(undef), 'AVG(NULL)' ],
    [ Avg_('id'), 'AVG(?)', 'id' ],
    [ Avg_(\'id'), 'AVG(id)', ],
    [ Avg_(Column('id')), 'AVG(id)' ],
    [ Avg_(Distinct(1)), 'AVG(DISTINCT ?)', 1 ],
    [ Avg_(Distinct(Column('id'))), 'AVG(DISTINCT id)' ],
    [ Avg_(Distinct(Boundable(1) == Boundable(2))), 'AVG(DISTINCT ? = ?)', 1, 2 ],

    [ Min_(undef), 'MIN(NULL)' ],
    [ Min_('id'), 'MIN(?)', 'id' ],
    [ Min_(\'id'), 'MIN(id)', ],
    [ Min_(Column('id')), 'MIN(id)' ],
    [ Min_(Distinct(1)), 'MIN(DISTINCT ?)', 1 ],
    [ Min_(Distinct(Column('id'))), 'MIN(DISTINCT id)' ],
    [ Min_(Distinct(Boundable(1) == Boundable(2))), 'MIN(DISTINCT ? = ?)', 1, 2 ],

    [ Max_(undef), 'MAX(NULL)' ],
    [ Max_('id'), 'MAX(?)', 'id' ],
    [ Max_(\'id'), 'MAX(id)', ],
    [ Max_(Column('id')), 'MAX(id)' ],
    [ Max_(Distinct(1)), 'MAX(DISTINCT ?)', 1 ],
    [ Max_(Distinct(Column('id'))), 'MAX(DISTINCT id)' ],
    [ Max_(Distinct(Boundable(1) == Boundable(2))), 'MAX(DISTINCT ? = ?)', 1, 2 ],

    # aliases
);

foreach (@test) {
    my ($e, $stmt, @bind) = @$_;
    is $e->stmt, $stmt, $stmt;
    is_deeply [ $e->bind ], \@bind, "bind for $stmt";
}

dies_ok { Count_() } '0-arg Count';
dies_ok { Avg_() } '0-arg Avg';
dies_ok { Min_() } '0-arg Min';
dies_ok { Max_() } '0-arg Max';

dies_ok { Count_(1,2) } '>=2-arg Count';
dies_ok { Avg_(1,2) } '>=2-arg Avg';
dies_ok { Min_(1,2) } '>=2-arg Min';
dies_ok { Max_(1,2) } '>=2-arg Max';

ok 1;


__END__
