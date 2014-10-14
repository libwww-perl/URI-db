package URI::mssql;
use base 'URI::_odbc';
our $VERSION = '0.16';

sub default_port { 1433 }
sub canonical_engine { 'mssql' }

1;
