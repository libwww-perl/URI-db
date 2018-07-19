package URI::_odbc;
use base 'URI::_db';
our $VERSION = '0.20';

sub dbi_driver   { 'ODBC' }

sub _dbi_param_map {
    my $self = shift;
    my $host = $self->host;
    my $port = $self->_port;

    # Just return the DSN if no host or port.
    return [ DSN => scalar $self->dbname ] unless $host || $port;

    return (
        [ Server   => $host                        ],
        [ Port     => $port || $self->default_port ],
        [ Database => scalar $self->dbname         ],
    );
}

1;
