package URI::vertica;
use base 'URI::pg';
our $VERSION = '0.14';

sub default_port { 5433 }

1;
