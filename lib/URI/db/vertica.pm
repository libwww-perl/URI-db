package URI::db::vertica;
use base 'URI::db::pg';
our $VERSION = '0.10';

sub default_port { 5433 }

1;
