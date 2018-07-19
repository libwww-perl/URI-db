package URI::db2;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 50000 }
sub dbi_driver   { 'DB2' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ HOSTNAME => scalar $self->host   ],
        [ PORT     => scalar $self->_port  ],
        [ DATABASE => scalar $self->dbname ],
    );
}

1;
