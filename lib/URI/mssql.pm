package URI::mssql;
use base 'URI::_odbc';
our $VERSION = '0.20';

sub default_port { 1433 }
sub canonical_engine { 'mssql' }

sub dbi_dsn {
    my $self   = shift;
    my $driver = shift or return $self->SUPER::dbi_dsn;
    my $lcd    = lc $driver;
    return $self->SUPER::dbi_dsn if $lcd eq 'odbc';

    my $class = $lcd eq 'ado'    ? 'URI::_ado'
        :       $lcd eq 'sybase' ? 'URI::sybase'
        :       die "Unknown driver: $driver\n";

    eval "require $class" or die;

    # Make a copy blessed into the alternate class to get its DSN.
    my $alt = bless \"$self" => $class;
    return $alt->dbi_dsn;
}

1;

=head1 Name

URI::mssql - Microsoft SQL Server database URI

=head1 Description

L<URI::db> format for Microsoft SQL Server.

=head1 Interface

The following differences exist compared to the C<URI::db> interface:

=head2 Instance Methods

=head3 C<dbi_dsn>

  my $dsn = $uri->dbi_dsn;
 $dsn = $uri->dbi_dsn($driver);

Extends the implementation of C<dbi_dsn> to support a driver argument. By
default, C<dbi_dsn> returns a DSN appropriate for use with L<DBD::ODBC>. Pass
"sybase" or "ado" to instead get a DSN appropriate to L<DBD::Sybase> or
L<DBD::ADO>, respectively. Note that DBD::ADO value is experimental and
subject to change. L<Feedback wanted|https://github.com/theory/uri-db/issues/11>.

=cut
