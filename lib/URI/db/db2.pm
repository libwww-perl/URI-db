package URI::db::db2;
use base 'URI::db';
our $VERSION = '0.10';

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
