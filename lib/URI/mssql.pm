package URI::mssql;
use base 'URI::_odbc';
our $VERSION = '0.17';

sub default_port { 1433 }
sub canonical_engine { 'mssql' }

sub dbi_dsn {
    my $self = shift;
    my $driver = shift or return $self->SUPER::dbi_dsn;
    return $self->SUPER::dbi_dsn if $driver eq 'ODBC';

    my $class = $driver eq 'ADO' ? 'URI::_ado'
        ? $driver eq 'Sybase' ? 'URI::sybase'
        : die "Unknown driver: $driver\n";
    eval "require $class" or die;
    return $class->new($self->canonical)->dbi_dsn;
}

1;
