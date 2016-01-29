package URI::mssql;
use base 'URI::_odbc';
our $VERSION = '0.17';

sub default_port     { 1433 }
sub canonical_engine { 'mssql' }

sub dbi_dsn { # change me? change ::sybase, ::_ado, and ::_odbc
    my $self = shift; # use Devel::Kit::TAP;d("mssql dbi_dsn()");
    my $driver = shift or return $self->SUPER::dbi_dsn;

    my $class =
        $driver eq 'ADO'    ? 'URI::_ado'
      : $driver eq 'Sybase' ? 'URI::sybase'
      : $driver eq 'ODBC'   ? 'URI::_odbc'
      :                       die "Unknown driver: $driver\n";

    eval "require $class;";
    die "Unloadable driver: $driver\n" if $@;

    bless( $self, $class );
    return $self->dbi_dsn;
}

1;
