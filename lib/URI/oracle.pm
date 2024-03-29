package URI::oracle;
use base 'URI::_db';
our $VERSION = '0.22';

sub default_port { 1521 }
sub dbi_driver   { 'Oracle' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host => scalar $self->host   ],
        [ port => scalar $self->_port  ],
        [ service_name => scalar $self->dbname ],
    );
}

1;
