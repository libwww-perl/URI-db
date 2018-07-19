package URI::maxdb;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 7673 }
sub dbi_driver   { 'MaxDB' }
sub canonical_engine { 'maxdb' }

sub _dbi_param_map { }

sub dbi_dsn {
    my $self = shift;
    return join (
        ':' => 'dbi', $self->dbi_driver,
        grep { defined } $self->host, $self->_port,
    ) . $self->path_query;
}

1;
