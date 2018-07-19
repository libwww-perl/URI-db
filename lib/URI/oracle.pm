package URI::oracle;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 1521 }
sub dbi_driver   { 'Oracle' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host => scalar $self->host   ],
        [ port => scalar $self->_port  ],
        [ sid  => scalar $self->dbname ],
    );
}

sub dbi_dsn {
    my $self = shift;
    my $params = $self->_dsn_params;
    $params =~ s/sid=// unless $self->host || $self->_port;
    return join ':' => 'dbi', $self->dbi_driver, $params
}

1;
