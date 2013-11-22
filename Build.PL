use strict;
use warnings;
use Module::Build;

Module::Build->new(
    module_name        => 'URI::db',
    license            => 'perl',
    configure_requires => { 'Module::Build' => '0.30', },
    build_requires     => {
        'Module::Build' => '0.30',
        'Test::More'    => '0.70',
    },
    requires => {
        'perl'          => 5.008001,
    },
    recommends => {
        'Test::Pod'           => '1.41',
        'Test::Pod::Coverage' => '1.06',
    },
    meta_merge => {
        resources => {
            homepage   => 'http://search.cpan.org/dist/URI-db/',
            bugtracker => 'http://github.com/theory/uri-db/issues/',
            repository => 'http://github.com/theory/uri-db/tree/',
        }
    },
)->create_build_script;
