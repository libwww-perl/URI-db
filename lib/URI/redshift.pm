package URI::redshift;
use base 'URI::pg';
our $VERSION = '0.18';

sub canonical_engine { 'redshift' }

1;
