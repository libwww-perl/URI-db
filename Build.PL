use strict;
use warnings;
use Module::Build;

Module::Build->new(
    module_name        => 'URI::db',
    license            => 'perl',
    configure_requires => { 'Module::Build' => '0.30', },
    build_requires     => {
        'Module::Build'   => '0.30',
        'Test::More'      => '0.88',
        'Test::Exception' => 0,
    },
    requires => {
        'perl'         => 5.008001,
        'URI'          => '1.40',
        'URI::Nested'  => '0.10',
    },
    meta_merge => {
        resources => {
            homepage   => 'https://search.cpan.org/dist/URI-db/',
            bugtracker => 'https://github.com/theory/uri-db/issues/',
            repository => 'https://github.com/theory/uri-db/',
        }
    },
)->create_build_script;
