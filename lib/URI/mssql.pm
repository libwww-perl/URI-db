package URI::mssql;
use base 'URI::_odbc';
our $VERSION = '0.17';

sub default_port { 1433 }
sub canonical_engine { 'mssql' }

1;
