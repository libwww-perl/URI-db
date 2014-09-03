package URI::vertica;
use base 'URI::_db';
our $VERSION = '0.14';

sub default_port { 5433 }
sub dbi_driver   { 'ODBC' }

sub _dbi_param_map {
    my $self = shift;
    my $host = $self->host;
    my $port = $self->_port;

    # Just return the DSN if no host or port.
    return [ DSN => scalar $self->dbname ] unless $host || $port;

    # Fetch the driver from the query params.
    require URI::QueryParam;
    return (
        [ Server   => $host ],
        [ Port     => $port ],
        [ Database => scalar $self->dbname ],
    );
}

1;

