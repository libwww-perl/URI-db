package URI::yugabyte;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 5433 }
sub dbi_driver   { 'Pg' }
sub canonical_engine { 'pg' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host   => scalar $self->host   ],
        [ port   => scalar $self->port   ], # Always pass the port
        [ dbname => scalar $self->dbname ],
    );
}

1;
