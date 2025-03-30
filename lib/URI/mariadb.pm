package URI::mariadb;
use base 'URI::mysql';
our $VERSION = '0.24';

sub dbi_driver   { 'MariaDB' }

1;
