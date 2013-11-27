package URI::db::interbase;
use base 'URI::db';
our $VERSION = '0.10';

sub default_port  { 3050 }
sub is_file_based { 1 }
sub dbi_driver    { 'InterBase' }

1;
