package URI::redshift;
use base 'URI::pg';
our $VERSION = '0.20';

sub canonical_engine { 'redshift' }

1;
