package URI::sqlserver;
use base 'URI::_db';
our $VERSION = '0.13';

sub default_port { 1433 }
# http://www.perlmonks.org/index.pl?node_id=669089
sub dbi_driver   { 'Sybase' }

1;
