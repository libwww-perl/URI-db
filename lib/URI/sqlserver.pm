package URI::sqlserver;
use base 'URI::_db';
our $VERSION = '0.11';

sub default_port { 1433 }
sub dbi_driver   { 'ODBC' }

sub _dbi_param_map {
    my $self = shift;
    my $host = $self->host;
    if (my $port = $self->_port) {
        $host = '' unless defined $host;
        $host .= ",$port";
    }
    return (
        [ Driver   => '{SQL Server}' ],
        [ Server   => $host          ],
        [ Database => $self->dbname  ],
    );
}

1;
