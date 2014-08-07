package URI::ldapdb;
use base 'URI::_db';
our $VERSION = '0.13';

sub dbi_driver   { 'LDAP' }

sub _dbi_param_map {
    my $self = shift;
    return (
        [ dbname => scalar $self->dbname ],
    );
}

sub dbi_dsn {
    my $self = shift;
    return join ':' => 'dbi', $self->dbi_driver, $self->dbname
}

1;
