package URI::mongodb;
use base 'URI::_db';
our $VERSION = '0.19';

sub default_port { 27017 }
sub canonical_engine { 'mongodb' }

1;
