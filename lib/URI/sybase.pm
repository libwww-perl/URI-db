package URI::sybase;
use base 'URI::_db';
our $VERSION = '0.17';

sub default_port { 2638 }
sub dbi_driver   { 'Sybase' }

sub dbi_dsn {
    my $self = shift;
    my $driver = shift or return $self->SUPER::dbi_dsn;
    return $self->SUPER::dbi_dsn if $driver eq 'Sybase';

    my $class =
        $driver eq 'ADO'  ? 'URI::_ado'
      : $driver eq 'ODBC' ? 'URI::_odbc'
      :                     die "Unknown driver: $driver\n";

    eval "require $class;";
    die "Unloadable driver: $driver\n" if $@;

    bless( $self, $class );
    return $self->dbi_dsn;
}

1;
