package URI::vertica;
use base 'URI::pg';
our $VERSION = '0.11';

sub default_port { 5433 }

1;
