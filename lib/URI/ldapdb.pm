package URI::ldapdb;
use base 'URI::_db';
our $VERSION = '0.20';

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

=head1 Name

URI::ldapdb - LDAP database URI

=head1 Description

Linkage between URI::db and DBD::LDAP. I would have used L<URI::ldap>, but
that was already taken for a module with slightly different intentions.

=head1 Contributed By

Brian T. Wightman <mlx@cpan.org>

=cut
