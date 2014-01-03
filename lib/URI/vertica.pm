package URI::vertica;
use base 'URI::pg';
our $VERSION = '0.12';

sub default_port { 5433 }

1;
