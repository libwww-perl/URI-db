package URI::sybase;
use base 'URI::_db';
our $VERSION = '0.24';

sub default_port { 2638 }
sub dbi_driver   { 'Sybase' }

1;
