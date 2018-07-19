package URI::mysql;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 3306 }
sub dbi_driver   { 'mysql' }
sub canonical_engine { 'mysql' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host     => scalar $self->host   ],
        [ port     => scalar $self->_port  ],
        [ database => scalar $self->dbname ],
    );
}

1;
