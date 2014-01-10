package URI::vertica;
use base 'URI::pg';
our $VERSION = '0.13';

sub default_port { 5433 }

1;
