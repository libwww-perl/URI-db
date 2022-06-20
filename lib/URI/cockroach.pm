package URI::cockroach;
use base 'URI::_db';
our $VERSION = '0.21';

sub default_port { 26257 }
sub dbi_driver   { 'Pg' }
sub canonical_engine { 'cockroach' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host   => scalar $self->host   ],
        [ port   => scalar $self->port   ], # Always pass the port
        [ dbname => scalar $self->dbname ],
    );
}
