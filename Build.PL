use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'SQL::Expr',
    license             => 'perl',
    dist_author         => 'Dexter B. Tad-y <dtady@cpan.org>',
    dist_version_from   => 'lib/SQL/Expr.pm',
    build_requires => {
        'Test::More'                    => 0,
        'Test::Exception'               => 0,
    },
    add_to_cleanup      => [ 'SQL-Expr-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

__END__
