package URI::_ado;
use base 'URI::mssql';
our $VERSION = '0.17';

sub dbi_driver   { 'ADO' }