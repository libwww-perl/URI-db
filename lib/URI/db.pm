package URI::db;

# db:engine:dbname
# db:engine:/path/to/some.db
# db:engine://dbname
# db:engine:///path/to/some.db
# db:engine:../relative.db
# db:engine://../relative.db
# db:engine://[netloc][:port][/dbname][?param1=value1&...]
# db:engine://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]

use strict;
use 5.008001;
use base 'URI::Nested';
use URI::_db;
our $VERSION = '0.20';

sub prefix       { 'db' }
sub nested_class { 'URI::_db' }

1;
__END__

=head1 Name

URI::db - Database URIs

=head1 Synopsis

  use URI;
  my $db_uri = URI->new('db:pg://user@localhost');
  my $pg_uri = URI->new('postgres://example.com/template1');
  my $sl_uri = URI->new('sqlite:/var/db/widgets.db');

=head1 Description

This class provides support for database URIs. They're inspired by
L<JDBC URIs|http://docs.oracle.com/cd/B14117_01/java.101/b10979/urls.htm#BEIJFHHB> and
L<PostgreSQL URIs|http://www.postgresql.org/docs/9.3/static/libpq-connect.html#LIBPQ-CONNSTRING>,
though they're a bit more formal. The specification for their format is
documented in L<F<README.md>|https:/github.com/theory/db-uri/>.

B<Warning:> This is an alpha release. I will do my best to preserve
functionality going forward, especially as L<Sqitch|App::Sqitch> uses this
module. However, as the database URI specification moves forward, changes
I<may> require backwards-incompatible changes. Caveat Hackor.

=head3 Format

A database URI is made up of these parts:

  db:engine:[//[user[:password]@][host][:port]/][dbname][?params][#fragment]

=over

=item C<db>

The literal string C<db> is the scheme that defines a database URI. Optional
for well-known engines.

=item C<engine>

A string identifying the database engine.

=item C<user>

The user name to use when connecting to the database.

=item C<password>

The password to use when connecting to the database.

=item C<host>

The host address to connect to.

=item C<port>

The network port to connect to.

=item C<dbname>

The name of the database. For some engines, this will be a file name, in which
case it may be a complete or local path, as appropriate.

=item C<params>

A URI-standard GET query string representing additional parameters to be
passed to the engine.

=item C<fragment>

Identifies a database part, such as a table or view.

=back

=head3 Examples

Some examples:

=over

=item * C<db:sqlite>

=item * C<db:sqlite:dbname>

=item * C<db:sqlite:/path/to/some.db>

=item * C<sqlite:../relative.db>

=item * C<db:firebird://localhost/%2Fpath/to/some.db>

=item * C<db:firebird://localhost//path/to/some.db>

=item * C<firebird://localhost/relative.db>

=item * C<db:pg://>

=item * C<db:pg://localhost>

=item * C<db:pg://localhost:5433>

=item * C<db:pg://localhost/mydb>

=item * C<db:pg://user@localhost>

=item * C<db:pg://user:secret@/mydb>

=item * C<pg:///mydb>

=item * C<pg://other@localhost/otherdb?connect_timeout=10&application_name=myapp>

=item * C<db://localhost/mydb>

=item * C<db:unknown://example.com/mydb>

=back

=head1 Interface

The following differences exist compared to the C<URI> class interface:

=head2 Class Method

=head3 C<default_port>

Returns the default port for the engine. This is a class method value defined
by each recognized URI engine.

=head2 Constructors

=head3 C<new>

  my $uri = URI::db->new($string);
  my $uri = URI::db->new($string, $base);

Always returns a URI::db object. C<$base> may be another URI object or string.
Unlike in L<URI>'s C<new()>, the scheme will always be applied to the URI if
it does not already have one.

=head2 Accessors

=head3 C<scheme>

  my $scheme = $uri->scheme;
  $uri->scheme( $new_scheme );

Gets or sets the scheme part of the URI. For C<db:> URIs, the scheme cannot be
changed to any value other than "db" (or any case variation thereof). For
non-C<db:> URIs, the scheme may be changed to any value, though the URI object
may no longer be a database URI.

=head3 C<engine>

  my $engine = $uri->engine;
  $uri->engine( $new_engine );

Gets or sets the engine part of the URI, which may be any valid URI scheme
value, though recognized engines provide additional context, such as the
C<default_port()> and a driver-specific C<dbi_dsn()>.

If called with an argument, it updates the engine, possibly changing the class
of the URI, and returns the old engine value.

=head3 C<canonical_engine>

  my $canonical_engine = $uri->canonical_engine;

Returns the canonical engine. A number of engine names are aliases for other
engines. This method will return the non-aliased engine name. For example, the
C<postgres> engine will return the canonical engine C<pg>, the C<sqlite3>
returns the canonical engine C<sqlite>, and C<maria> returns the canonical
engine C<mysql>.

=head3 C<dbname>

  my $dbname = $uri->dbname;
  $uri->dbname( $new_dbname );

Gets or sets the name of the database. If called with an argument, the path
will also be updated.

=head3 C<host>

  my $host = $uri->host;
  $uri->host( $new_host );

Gets or sets the host to connect to.

=head3 C<port>

  my $port = $uri->port;
  $uri->port( $new_port );

Gets or sets the port to connect to.

=head3 C<user>

  my $user = $uri->user;
  $uri->user( $new_user );

Gets or sets the user name.

=head3 C<password>

  my $password = $uri->password;
  $uri->password( $new_password );

Gets or sets the password.

=head3 C<uri>

Returns the underlying engine URI. For URIs starting with C<db:>, this will be
the URI that follows. For database URIs without C<db:>, the URI itself will be
returned.

=head2 Instance Methods

=head3 C<has_recognized_engine>

  my $has_recognized_engine = $uri->has_recognized_engine;

Returns true if the engine is recognized by URI::db, and false if it is not. A
recognized engine is simply one that inherits from C<URI::_db>.

=head3 C<query_params>

  my @params = $uri->query_params;

Returns a list of key/value pairs representing all query parameters.
Parameters specified more than once will be returned more than once, so avoid
assigning to a hash. If you want a hash, use L<URI::QueryParam>'s
C<query_from_hash()>, where duplicate keys lead to an array of values for that
key:

  use URI::QueryParam;
  my $params = $uri->query_form_hash;

=head3 C<dbi_driver>

  if ( my $driver = $uri->dbi_driver ) {
      eval "require DBD::$driver" or die;
  }

Returns a string representing the L<DBI> driver name for the database engine,
if one is known. Returns C<undef> if no driver is known.

=head3 C<dbi_dsn>

  DBI->connect( $uri->dbi_dsn, $uri->user, $uri->password );

Returns a L<DBI> DSN appropriate for use in a call to C<< DBI->connect >>. The
attributes will usually be pulled from the URI host name, port, and database
name, as well as the query parameters. If no driver is known for the URI, the
C<dbi:$driver:> part of the DSN will be omitted, in which case you can use the
C<$DBI_DRIVER> environment variable to identify an appropriate driver. If the
URI supports multiple drivers, pass the name of the one you want to
C<dbi_dsn()>. Currently only URI::myssql supports alternate drivers, ADO,
ODBC, or Sybase. Otherwise, each database URI does its best to create a valid
DBI DSN. Some examples:

  | URI                                  | DSN                                              |
  |--------------------------------------+--------------------------------------------------|
  | db:pg:try                            | dbi:Pg:dbname=try                                |
  | db:mysql://localhost:33/foo          | dbi:mysql:host=localhost;port=33;database=foo    |
  | db:db2://localhost:33/foo            | dbi:DB2:HOSTNAME=localhost;PORT=33;DATABASE=foo  |
  | db:vertica:dbadmin                   | dbi:ODBC:DSN=dbadmin                             |
  | db:mssql://foo.com/pubs?Driver=MSSQL | dbi:ODBC:Host=foo.com;Database=pubs;Driver=MSSQL |

=head3 C<dbi_params>

  my @params = $uri->dbi_params;

Returns a list of key/value pairs used as parameters in the L<DBI> DSN,
including query parameters. Parameters specified more than once will be
returned more than once, so avoid assigning to a hash.

=head3 C<abs>

  my $abs = $uri->abs( $base_uri );

For C<db:> URIs, simply returns the URI::db object itself. For Non-C<db:>
URIs, the behavior is the same as for L<URI> including respect for
C<$URI::ABS_ALLOW_RELATIVE_SCHEME>.

=head3 C<rel>

  my $rel = $uri->rel( $base_uri );

For C<db:> URIs, simply returns the URI::db object itself. For Non-C<db:>
URIs, the behavior is the same as for L<URI>.

=head3 C<canonical>

  my $canonical_uri = $uri->canonical;

Returns a normalized version of the URI. This behavior is the same for other
URIs, except that the engine will be replaced with the value of
C<canonical_engine> if it is not already the canonical engine.

=head1 Support

This module is stored in an open
L<GitHub repository|https://github.com/theory/uri-db/>. Feel free to fork and
contribute!

Please file bug reports via
L<GitHub Issues|https://github.com/theory/uri-db/issues/> or by sending mail to
L<bug-URI-db@rt.cpan.org|mailto:bug-URI-db@rt.cpan.org>.

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 Copyright and License

Copyright (c) 2013-2016 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
