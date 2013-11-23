#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use URI;
use URI::QueryParam;

for my $spec (
    [ db         => undef ],
    [ postgresql => 5432  ],
    [ mysql      => 3306  ],
    [ sqlite     => undef ],
    [ oracle     => 1521  ],
    [ cubrid     => 1523  ], # ?
    [ firebird   => 3050  ],
    [ sqlserver  => 1433  ],
    [ db2        => 50000 ], # ?
    [ ingres     => 1524  ],
    [ sybase     => 2638  ],
    [ informix   => 1526  ], # ?
    [ teradata   => 1025  ],
    [ interbase  => 3050  ],
    [ unify      => 27117 ], # ?
    [ mongodb    => 27017 ],
    [ monetdb    => 50000 ], # ?
    [ maxdb      => 7673  ], # ?
    [ impala     => 21000 ],
    [ couchdb    => 5984  ],
    [ hive       => 10000 ],
) {
    my ($scheme, $port) = @{ $spec };

    isa_ok my $uri = URI->new("$scheme:"), "URI::$scheme";
    isa_ok $uri, 'URI::db' unless $scheme eq 'db';
    is $uri->scheme, $scheme, qq{Simple URI scheme should be "$scheme"};
    is $uri->db_name, undef, 'Simple URI db name should be undef';
    is $uri->host, undef, 'Simple URI host should be undef';
    is $uri->port, $port, 'Simple URI port should be undef';
    is $uri->user, undef, 'Simple URI user should be undef';
    is $uri->password, undef, 'Simple URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'Simple URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://"), "URI::$scheme";
    is $uri->scheme, $scheme, qq{Hostless URI scheme should be "$scheme"};
    is $uri->db_name, undef, 'Hostless URI db name should be undef';
    is $uri->host, '', 'Hostless URI host should be ""';
    is $uri->port, $port, 'Hostless URI port should be undef';
    is $uri->user, undef, 'Hostless URI user should be undef';
    is $uri->password, undef, 'Hostless URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'Hostless URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://localhost"), "URI::$scheme";
    is $uri->scheme, $scheme, qq{Localhost URI scheme should be "$scheme"};
    is $uri->db_name, undef, 'Localhost URI db name should be undef';
    is $uri->host, 'localhost', 'Localhost URI host should be "localhost"';
    is $uri->port, $port, 'Localhost URI port should be undef';
    is $uri->user, undef, 'Localhost URI user should be undef';
    is $uri->password, undef, 'Localhost URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'Localhost URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://example.com:5433"), "URI::$scheme";
    is $uri->scheme, $scheme, qq{Host+Port URI scheme should be "$scheme"};
    is $uri->db_name, undef, 'Host+Port URI db name should be undef';
    is $uri->host, 'example.com', 'Host+Port URI host should be "example.com"';
    is $uri->port, 5433, 'Host+Port URI port should be 5433';
    is $uri->user, undef, 'Host+Port URI user should be undef';
    is $uri->password, undef, 'Host+Port URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'Host+Port URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://example.com/mydb"), "URI::$scheme";
    is $uri->scheme, $scheme, qq{DB URI scheme should be "$scheme"};
    is $uri->db_name, 'mydb', 'DB URI db name should be "mydb"';
    is $uri->host, 'example.com', 'DB URI host should be "example.com"';
    is $uri->port, $port, 'DB URI port should be undef';
    is $uri->user, undef, 'DB URI user should be undef';
    is $uri->password, undef, 'DB URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'DB URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://user\@localhost//fullpathdb"), "URI::$scheme";
    is $uri->scheme, $scheme, qq{User URI scheme should be "$scheme"};
    is $uri->db_name, '/fullpathdb', 'User URI db name should be "/fullpathdb"';
    is $uri->host, 'localhost', 'User URI host should be "localhost"';
    is $uri->port, $port, 'User URI port should be undef';
    is $uri->user, 'user', 'User URI user should be "user"';
    is $uri->password, undef, 'User URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'User URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://user:secret\@localhost"), "URI::$scheme";
    is $uri->scheme, $scheme, qq{Password URI scheme should be "$scheme"};
    is $uri->db_name, undef, 'Password URI db name should be undef';
    is $uri->host, 'localhost', 'Password URI host should be "localhost"';
    is $uri->port, $port, 'Password URI port should be undef';
    is $uri->user, 'user', 'Password URI user should be "user"';
    is $uri->password, 'secret', 'Password URI password should be "secret"';
    is_deeply $uri->query_form_hash, {}, 'Password URI query params should be empty by default';

    isa_ok $uri = URI->new("$scheme://other\@localhost/otherdb?foo=bar&baz=yow"),
        "URI::$scheme";
    is $uri->scheme, $scheme, qq{Query URI scheme should be "$scheme"};
    is $uri->db_name, 'otherdb', 'Query URI db name should be "otherdb"';
    is $uri->host, 'localhost', 'Query URI host should be "localhost"';
    is $uri->port, $port, 'Query URI port should be undef';
    is $uri->user, 'other', 'Query URI user should be "other"';
    is $uri->password, undef, 'Query URI password should be undef';
    is_deeply $uri->query_form_hash, { foo => 'bar', baz => 'yow'},
        'Query URI query params should be populated';
}

done_testing;
