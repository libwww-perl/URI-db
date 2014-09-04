package URI::sqlserver;
use base 'URI::_db';
our $VERSION = '0.15';

sub default_port { 1433 }
# http://www.perlmonks.org/index.pl?node_id=669089
sub dbi_driver   { 'Sybase' }
sub canonical_engine { 'sqlserver' }

1;
