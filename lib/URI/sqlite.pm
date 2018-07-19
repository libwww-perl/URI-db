package URI::sqlite;
use base 'URI::_db';
our $VERSION = '0.20';

sub dbi_driver { 'SQLite' }
sub canonical_engine { 'sqlite' }
sub _dbi_param_map {
    return [ dbname => scalar shift->dbname ];
}

1;
