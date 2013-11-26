package URI::db::cubrid;
use base 'URI::db';
our $VERSION = '0.10';

sub default_port { 1523 }
sub dbi_driver   { 'cubrid' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host     => scalar $self->host   ],
        [ port     => scalar $self->_port  ],
        [ database => scalar $self->dbname ],
    );
}

1;
