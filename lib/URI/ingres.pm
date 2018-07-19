package URI::ingres;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 1524 }
sub dbi_driver   { 'Ingres' }

sub _dbi_param_map { }

sub dbi_dsn {
    my $self = shift;
    return join ':' => 'dbi', $self->dbi_driver,
           join ';' => $self->dbname, ($self->_dsn_params || ());
}

1;
