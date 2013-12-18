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
use 5.8.1;
use base 'URI::_db';
our $VERSION = '0.10';
use overload '""' => 'as_string', fallback => 1;

my %implementor;

sub _init {
    my ($class, $str, $scheme) = @_;

    $str =~ s/^db://;

    my ($engine, $impclass);
    if ($str =~ /^($URI::scheme_re):/so) {
        $engine = $1;
    } else {
        # No engine detected.
        return $class->_db_init($str);
    }

    $impclass = $implementor{$engine} ||= do {
        # make it a legal perl identifier
        (my $pkg = $engine) =~ s/-/_/g;
        $engine = "_$engine" if $engine =~ /^\d/;

        $pkg = "URI::db::$pkg";

        no strict 'refs';
        unless (@{"${pkg}::ISA"}) {
            # Try to load it
            eval "require $pkg";
            die $@ if $@ && $@ !~ /Can\'t locate.*in \@INC/;
            $pkg = "URI::db" unless @{"${pkg}::ISA"};
        }
        $pkg;
    };

    return $impclass->_db_init($str, $engine);
}

sub _db_init {
    my ($class, $self, $engine) = @_;
    bless \$self => $class;
}

sub scheme { 'db' }

sub engine {
    my $self = shift;
    return $self->SUPER::scheme unless @_;
    # Changing the engine can change the class.
    my $class = ref $self;
    my $old = $self->SUPER::scheme(@_);
    my $newself = $class->_init( $self->as_string );
    $$self = $$newself;
    bless $self, ref $newself;
    return $old;
}

sub has_recognized_engine {
    ref $_[0] ne __PACKAGE__;
}

sub as_string {
    my $self = shift;
    return $self->scheme . ':' . $self->SUPER::as_string(@_);
}

1;
__END__

=head1 Name

URI::db - Database URIs

=head1 Synopsis

  use URI;
  my $uri = URI->new('db:pg://user@localhost');

=head1 Description

This class provides support for database URIs. They're inspired by
L<JDBC URIs|http://docs.oracle.com/cd/B14117_01/java.101/b10979/urls.htm#BEIJFHHB> and
L<PostgreSQL URIs|http://www.postgresql.org/docs/9.3/static/libpq-connect.html#LIBPQ-CONNSTRING>,
though they're a bit more formal. The specification for their format is
documented in L<F<README.md>|https:/github.com/theory/db-uri/>.

=head3 Format

A database URI is made up of these parts:

  db:engine:[//[user[:password]@][host][:port]/][dbname][?params]

=over

=item C<db>

The literal string C<db> is the scheme that defines a database URI.

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

=back

=head3 Examples

Some examples:

=over

=item C<db:sqlite>

=item C<db:sqlite:dbname>

=item C<db:sqlite:/path/to/some.db>

=item C<db:sqlite:../relative.db>

=item C<db:firebird://localhost/%2Fpath/to/some.db>

=item C<db:firebird://localhost//path/to/some.db>

=item C<db:firebird://localhost/relative.db>

=item C<db:pg://>

=item C<db:pg://localhost>

=item C<db:pg://localhost:5433>

=item C<db:pg://localhost/mydb>

=item C<db:pg://user@localhost>

=item C<db:pg://user:secret@/mydb>

=item C<db:pg:///mydb>

=item C<db:pg://other@localhost/otherdb?connect_timeout=10&application_name=myapp>

=back

=head1 Interface

The following differences exist compared to the C<URI> class interface:

=head2 Class Method

=head3 C<default_port>

Returns the default port for the engine. This is a class method value defined
by each recognized URI engine.

=head2 Accessors

=head3 C<engine>

  my $engine = $uri->engine;
  $uri->engine( $new_engine );

Gets or sets the engine part of the URI, which may be any valid URI scheme
value, though recognized engines provide additional context, such as the
C<default_port()> and a driver-specific C<dbi_dsn()>.

If called with an argument, it updates the engine, possibly changing the
class of the URI, and returns the old engine value.

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

=head2 Instance Methods

=head3 C<has_recognized_engine>

  my $has_recognized_engine = $uri->has_recognized_engine;

Returns true if the engine is recognized by URI::db, and false if it is not. A
recognized engine is simply one that has an implementation in the C<URI::db>
namespace.

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

  DBI->connect( $uri->dbi_dsn, $uri->user, $uri->pass );

Returns a L<DBI> DSN appropriate for use in a call to C<< DBI->connect >>. If
no driver is known for the URI, the C<dbi:$driver:> part of the DSN will be
omitted, in which case you can use the C<$DBI_DRIVER> environment variable to
identify an appropriate driver.

=head3 C<dbi_params>

  my @params = $uri->dbi_params;

Returns a list of key/value pairs used as parameters in the L<DBI> DSN,
including query parameters. Parameters specified more than once will be
returned more than once, so avoid assigning to a hash.

=head1 Support

This module is stored in an open
L<GitHub repository|http://github.com/theory/uri-db/>. Feel free to fork and
contribute!

Please file bug reports via
L<GitHub Issues|http://github.com/theory/uri-db/issues/> or by sending mail to
L<bug-URI-db@rt.cpan.org|mailto:bug-URI-db@rt.cpan.org>.

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 Copyright and License

Copyright (c) 2013 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
