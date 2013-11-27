package URI::db::sqlite;
use base 'URI::db';
our $VERSION = '0.10';

sub is_file_based  { 1 }
sub dbi_driver     { 'SQLite' }
sub _dbi_param_map {
    return [ dbname => scalar shift->dbname ];
}


1;
