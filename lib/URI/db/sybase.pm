package URI::db::sybase;
use base 'URI::db';
our $VERSION = '0.10';

sub default_port { 2638 }
sub dbi_driver   { 'Sybase' }

1;
