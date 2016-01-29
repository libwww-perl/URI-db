package URI::_ado;
use base 'URI::_odbc';
our $VERSION = '0.17';

sub dbi_driver   { 'ADO' }

sub dbi_dsn { # change me? change ::mssql, ::sybase, and ::_odbc
    my $self = shift; # use Devel::Kit::TAP;d("_ado dbi_dsn()");
    my $driver = shift or return $self->SUPER::dbi_dsn;
    return $self->SUPER::dbi_dsn if $driver eq 'ADO';

    my $class =
        $driver eq 'ODBC'  ? 'URI::_odbc'
      : $driver eq 'Sybase' ? 'URI::sybase'
      :                     die "Unknown driver: $driver\n";

    eval "require $class;";
    die "Unloadable driver: $driver\n" if $@;

    bless( $self, $class );
    return $self->dbi_dsn;
}