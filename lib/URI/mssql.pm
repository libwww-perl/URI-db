package URI::mssql;
use base 'URI::_ado';
our $VERSION = '0.17';

sub default_port { 1433 }
sub canonical_engine { 'mssql' }

sub dbi_dsn {
    my $self   = shift;
    my $driver = shift or return $self->SUPER::dbi_dsn;
    my $lcd    = lc $driver;
    return $self->SUPER::dbi_dsn if $driver eq 'ado';

    my $class = $lcd eq 'odbc'   ? 'URI::_odbc'
        :       $lcd eq 'sybase' ? 'URI::sybase'
        :       die "Unknown driver: $driver\n";

    eval "require $class" or die;
    return $class->new($self)->dbi_dsn;
}

1;
