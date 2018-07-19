package URI::monetdb;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 50000 }
sub dbi_driver   { 'monetdb' }
sub canonical_engine { 'monetdb' }

sub _dbi_param_map {
    my $self = shift;
    # DBD::monetdb had no database name support.
    return (
        [ host => scalar $self->host  ],
        [ port => scalar $self->_port ],
    );
}

1;
