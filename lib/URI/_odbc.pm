package URI::_odbc;
use base 'URI::_db';
our $VERSION = '0.17';

sub dbi_driver   { 'ODBC' }

sub dbi_dsn { # change me? change ::mssql, ::_ado, and ::_sybase
    my $self = shift; # use Devel::Kit::TAP;d("_odbc dbi_dsn()");
    my $driver = shift or return $self->SUPER::dbi_dsn;
    return $self->SUPER::dbi_dsn if $driver eq 'ODBC';

    my $class =
        $driver eq 'ADO'  ? 'URI::_ado'
      : $driver eq 'Sybase' ? 'URI::sybase'
      :                     die "Unknown driver: $driver\n";

    eval "require $class;";
    die "Unloadable driver: $driver\n" if $@;

    bless( $self, $class );
    return $self->dbi_dsn;
}

sub _dbi_param_map {
    my $self = shift;
    my $host = $self->host;
    my $port = $self->_port;

    # Just return the DSN if no host or port.
    return [ DSN => scalar $self->dbname ] unless $host || $port;

    # Fetch the driver from the query params.
    require URI::QueryParam;
    return (
        [ Server   => $host                        ],
        [ Port     => $port || $self->default_port ],
        [ Database => scalar $self->dbname         ],
    );
}

1;
